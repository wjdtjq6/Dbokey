//
//  AuthenticationInterceptor.swift
//  Dbokey
//
//  Created by 소정섭 on 10/27/24.
//

import UIKit
import Alamofire

// MARK: - AuthenticationManager
final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {}
    
    lazy var session: Session = {
        let interceptor = AuthInterceptor()
        return Session(interceptor: interceptor)
    }()
}

// MARK: - AuthInterceptor
final class AuthInterceptor: RequestInterceptor {
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // Router의 header를 사용하도록 수정
        if let url = urlRequest.url?.absoluteString {
            var headers: [String: String] = [
                Header.sesacKey.rawValue: APIKey.SesacKey,
                Header.contentType.rawValue: Header.json.rawValue
            ]
            
            // refresh 요청이 아닐 경우에만 토큰 추가
            if !url.contains("/auth/refresh") {
                headers[Header.authorization.rawValue] = UserDefaultsManager.shared.token
            }
            
            // multipart 요청인 경우 Content-Type 변경
            if url.contains("/posts/files") || url.contains("/users/me/profile") {
                headers[Header.contentType.rawValue] = Header.multipart.rawValue
            }
            
            urlRequest.headers = HTTPHeaders(headers)
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        lock.lock() ; defer { lock.unlock() }
        
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetry)
            return
        }
        
        switch response.statusCode {
        case 419: // Access Token expired
            requestsToRetry.append(completion)
            
            guard !isRefreshing else { return }
            
            isRefreshing = true
            refreshAccessToken { [weak self] succeeded in
                guard let self = self else { return }
                
                self.lock.lock() ; defer { self.lock.unlock() }
                
                self.requestsToRetry.forEach { $0(succeeded ? .retry : .doNotRetry) }
                self.requestsToRetry.removeAll()
                self.isRefreshing = false
            }
            
        case 418: // Refresh Token expired
            handleRefreshTokenExpiration()
            completion(.doNotRetry)
            
        default:
            completion(.doNotRetry)
        }
    }
    
    private func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        do {
            var request = try Router.refresh.asURLRequest()
            // 리프레시 토큰으로 요청
            guard let refreshToken = UserDefaultsManager.shared.refreshToken else {
                completion(false)
                return
            }
            
            request.headers = [
                "Authorization": refreshToken,
                "Content-Type": "application/json",
                "SesacKey": APIKey.SesacKey
            ]
            
            AF.request(request)
                .responseDecodable(of: RefreshModel.self) { response in
                    if let statusCode = response.response?.statusCode {
                        print("Refresh Token Response Status:", statusCode)
                    }
                    
                    switch response.result {
                    case .success(let model):
                        UserDefaultsManager.shared.token = model.accessToken
                        completion(true)
                    case .failure(let error):
                        print("Refresh Token Error:", error)
                        completion(false)
                    }
                }
        } catch {
            completion(false)
        }
    }
    private func handleRefreshTokenExpiration() {
        DispatchQueue.main.async {
            // UserDefaultsManager의 clearAll 메서드 사용
            UserDefaultsManager.shared.clearAll()
            
            // 로그인 화면으로 이동
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                UIView.transition(with: window,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: {
                    window.rootViewController = navController
                })
            }
        }
    }
}
