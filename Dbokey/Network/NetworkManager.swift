//
//  NetworkManager.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation
import Alamofire
import RxSwift
import UIKit

struct NetworkManager {
    private init() {}
    
    // MARK: - Auth Session for Protected APIs
    private static var authSession: Session {
        return AuthenticationManager.shared.session
    }
    
    struct EmptyResponse: Decodable {}

    private static func refreshToken() -> Single<RefreshModel> {
        return Single.create { observer in
            guard let refreshToken = UserDefaultsManager.shared.refreshToken else {
                print("⛔️ Refresh Token is missing")
                observer(.failure(NetworkError.refreshTokenExpired))
                return Disposables.create()
            }
            
            print("🔑 Using Refresh Token:", refreshToken)
            
            var request = try! Router.refresh.asURLRequest()
            print("📝 Original Headers:", request.headers)
            
            request.headers = [
                "Authorization": refreshToken,
                "Content-Type": "application/json",
                "SesacKey": APIKey.SesacKey
            ]
            
            print("📝 Updated Headers:", request.headers)
            
            AF.request(request)
                .responseData { response in  // 원본 데이터 확인
                    print("📡 Raw Response:", String(data: response.data ?? Data(), encoding: .utf8) ?? "No Data")
                }
                .responseDecodable(of: RefreshModel.self) { response in
                    print("📡 Status Code:", response.response?.statusCode ?? -1)
                    
                    switch response.result {
                    case .success(let model):
                        print("✅ Token Refresh Success")
                        UserDefaultsManager.shared.token = model.accessToken
                        observer(.success(model))
                    case .failure(let error):
                        print("❌ Token Refresh Error:", error)
                        
                        // 401 에러인 경우 로그인 화면으로 이동
                        if response.response?.statusCode == 401 {
                            DispatchQueue.main.async {
                                UserDefaultsManager.shared.clearAll()
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    let loginVC = LoginViewController()
                                    let navController = UINavigationController(rootViewController: loginVC)
                                    window.rootViewController = navController
                                }
                            }
                            observer(.failure(NetworkError.refreshTokenExpired))
                        } else {
                            observer(.failure(error))
                        }
                    }
                }
            
            return Disposables.create()
        }
    }
    
    private static func requestWithRetry<T: Decodable>(_ urlRequest: URLRequestConvertible) -> Single<T> {
        return Single<T>.create { observer in
            authSession.request(urlRequest)
                .validate(statusCode: 200...299)
                .responseDecodable(of: T.self) { response in
                    switch response.response?.statusCode {
                    case 419:
                        refreshToken()
                            .flatMap { _ in requestWithRetry(urlRequest) }
                            .subscribe(
                                onSuccess: { observer(.success($0)) },
                                onFailure: { observer(.failure($0)) }
                            )
                            .disposed(by: DisposeBag())
                        
                    case 418:
                        DispatchQueue.main.async {
                            UserDefaultsManager.shared.clearAll()
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                let loginVC = LoginViewController()
                                let navController = UINavigationController(rootViewController: loginVC)
                                window.rootViewController = navController
                            }
                        }
                        observer(.failure(NetworkError.refreshTokenExpired))
                        
                    default:
                        switch response.result {
                        case .success(let value):
                            observer(.success(value))
                        case .failure(let error):
                            observer(.failure(error))
                        }
                    }
                }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Public APIs without Auth
    
    static func emailCheck(email: String) -> Single<EmailCheckModel> {
        return Single.create { observer in
            let query = emailCheckQuery(email: email)
            let request = try! Router.emailCheck(query: query).asURLRequest()
            
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseDecodable(of: EmailCheckModel.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer(.success(value))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func createJoin(email: String, password: String, nick: String, phoneNum: String, birthDay: String) -> Single<SignModel> {
        return Single.create { observer in
            let query = JoinQuery(email: email, password: password, nick: nick, phoneNum: phoneNum, birthDay: birthDay)
            let request = try! Router.join(query: query).asURLRequest()
            
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseDecodable(of: SignModel.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer(.success(value))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func createLogin(email: String, password: String) -> Single<SignModel> {
        return Single.create { observer in
            let query = LoginQuery(email: email, password: password)
            let request = try! Router.login(query: query).asURLRequest()
            
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseDecodable(of: SignModel.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer(.success(value))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Protected APIs with Auth
    
    static func withdraw() -> Single<SignModel> {
        let request = try! Router.withdraw.asURLRequest()
        return requestWithRetry(request)
    }
    
    static func deletePost(post_id: String) -> Single<Bool> {
        let request = try! Router.deletePost(postID: post_id).asURLRequest()
        return requestWithRetry(request as URLRequestConvertible)
            .map { (_: EmptyResponse) in true }
            .catch { error in
                print("Delete post error:", error)
                return .just(false)
            }
    }
    
    static func editPost(post_id: String, title: String, content: String, content1: String, content2: String, content3: String, price: Int, product_id: String, files: [String]) -> Single<PostData> {
        let query = writeEditPostQuery(title: title, content: content, content1: content1, content2: content2, content3: content3, price: price, product_id: product_id, files: files)
        let request = try! Router.editPost(query: query, postID: post_id).asURLRequest()
        return requestWithRetry(request)
    }
    
    static func usersPost(userID: String, next: String, limit: String) -> Single<ViewPostModel> {
        var request = try! Router.usersPost(userID: userID, next: next, limit: limit).asURLRequest()
        if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = Router.usersPost(userID: userID, next: next, limit: limit).queryItems
            request.url = urlComponents.url
        }
        return requestWithRetry(request)
    }
    
    static func uploadFiles(images: [Data?]) -> Single<uploadFilesModel> {
        return Single.create { observer in
            let url = APIKey.BaseURL + "v1/posts/files"
            
            let header: HTTPHeaders = [
                Header.sesacKey.rawValue: APIKey.SesacKey,
                Header.authorization.rawValue: UserDefaultsManager.shared.token,
                Header.contentType.rawValue: Header.multipart.rawValue
            ]
            
            AF.upload(multipartFormData: { multipartFormData in
                for (index, imageData) in images.enumerated() {
                    if let data = imageData {
                        multipartFormData.append(data, withName: "files", fileName: "image\(index + 1).jpg", mimeType: "image/jpg")
                    }
                }
            }, to: url, headers: header)
            .validate(statusCode: 200...299)
            .responseDecodable(of: uploadFilesModel.self) { response in
                switch response.response?.statusCode {
                case 400:
                    observer(.failure(NetworkError.badRequest))
                case 419:
                    refreshToken()
                        .flatMap { _ in uploadFiles(images: images) }
                        .subscribe(
                            onSuccess: { observer(.success($0)) },
                            onFailure: { observer(.failure($0)) }
                        )
                        .disposed(by: DisposeBag())
                default:
                    switch response.result {
                    case .success(let value):
                        observer(.success(value))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    static func uploadPostContents(title: String, content: String, content1: String, content2: String, content3: String, price: Int, product_id: String, files: [String]) -> Single<PostData> {
        let query = writeEditPostQuery(title: title, content: content, content1: content1, content2: content2, content3: content3, price: price, product_id: product_id, files: files)
        let request = try! Router.writePost(query: query).asURLRequest()
        return requestWithRetry(request)
    }
    
    static func likePost(postID: String, like_status: Bool) -> Single<likeModel> {
        let query = likePostQuery(like_status: like_status)
        let request = try! Router.likePost(postID: postID, query: query).asURLRequest()
        return requestWithRetry(request)
    }
    
    static func viewPost2(next: String, limit: String, productId: String) -> Single<ViewPostModel> {
        var request = try! Router.viewPost2(next: next, limit: limit, productId: productId).asURLRequest()
        if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = Router.viewPost2(next: next, limit: limit, productId: productId).queryItems
            request.url = urlComponents.url
        }
        return requestWithRetry(request)
    }
    
    static func viewPost(next: String, limit: String, productId: String, productId1: String, productId2: String, productId3: String, productId4: String, productId5: String) -> Single<ViewPostModel> {
        var request = try! Router.viewPost(next: next, limit: limit, productId: productId, productId1: productId1, productId2: productId2, productId3: productId3, productId4: productId4, productId5: productId5).asURLRequest()
        if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = Router.viewPost(next: next, limit: limit, productId: productId, productId1: productId1, productId2: productId2, productId3: productId3, productId4: productId4, productId5: productId5).queryItems
            request.url = urlComponents.url
        }
        return requestWithRetry(request)
    }
}

// MARK: - NetworkError
enum NetworkError: Error {
    case refreshTokenExpired
    case tokenRefreshFailed
    case badRequest
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .refreshTokenExpired:
            return "세션이 만료되었습니다. 다시 로그인해주세요."
        case .tokenRefreshFailed:
            return "인증에 실패했습니다. 다시 시도해주세요."
        case .badRequest:
            return "잘못된 요청입니다. 다시 시도해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
