//
//  NetworkManager.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation
import Alamofire
import RxSwift

struct NetworkManager {
    private init() {}
    
    static func likePost(postID: String, like_status: Bool, completion: @escaping (Result<likeModel, Error>) -> Void) {
        let query = likePostQuery(like_status: like_status)
        let request = try! Router.likePost(postID: postID, query: query).asURLRequest()
        print("Request Body: \(request.httpBody?.base64EncodedString())")
        AF.request(request)
            .validate(statusCode: 200...299)
            .responseDecodable(of: likeModel.self) { response in
                print("statusCode", response.response?.statusCode)
                switch response.result {
                case .success(let success):
                    print("성공 안보이지?")
                    completion(.success(success))
                case .failure(let error):
                    print("실패 안보이지?")
                    completion(.failure(error))
                }
            }
    }
    static func viewPost2(next: String, limit: String, productId: String) -> Single<ViewPostModel> {
        var request = try! Router.viewPost2(next: next, limit: limit, productId: productId).asURLRequest()
        // URLComponents를 사용해 queryItems를 추가
        if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = Router.viewPost2(next: next, limit: limit, productId: productId).queryItems
            request.url = urlComponents.url
        }
        print("Complete URL: \(request.url?.absoluteString ?? "Invalid URL")")
        return Single.create { observer in
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseDecodable(of: ViewPostModel.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer(.success(success))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }.debug("viewPost2 API 통신")
    }
    static func viewPost(next: String, limit: String, productId: String, productId1: String, productId2: String, productId3: String, productId4: String, productId5: String) -> Single<ViewPostModel> {
        var request = try! Router.viewPost(next: next, limit: limit, productId: productId, productId1: productId1, productId2: productId2, productId3: productId3, productId4: productId4, productId5: productId5).asURLRequest()
        // URLComponents를 사용해 queryItems를 추가
        if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
            urlComponents.queryItems = Router.viewPost(next: next, limit: limit, productId: productId, productId1: productId1, productId2: productId2, productId3: productId3, productId4: productId4, productId5: productId5).queryItems
            request.url = urlComponents.url
        }
        print("Complete URL: \(request.url?.absoluteString ?? "Invalid URL")")
        return Single.create { observer in
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseDecodable(of: ViewPostModel.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer(.success(success))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }.debug("viewPost API 통신")
    }
    static func emailCheck(email: String) -> Single<EmailCheckModel> {
        let query = emailCheckQuery(email: email)
        let request = try! Router.emailCheck(query: query).asURLRequest()
        return Single.create { observer in
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseDecodable(of: EmailCheckModel.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer(.success(success))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }.debug("iTunes API 통신")
    }
    //TODO: RxSwift로 변경
    static func createJoin(email: String, passwrod: String, nick: String, phoneNum: String, birthDay: String, completion: @escaping(Bool)->() ) {
        do {
            let query = JoinQuery(email: email, password: passwrod, nick: nick, phoneNum: phoneNum, birthDay: birthDay)
            let request = try Router.join(query: query).asURLRequest()
            AF.request(request).responseDecodable(of: SignModel.self) { response in
                switch response.result {
                case .success(let success):
                    print("OK",success)
                    completion(true)
                case .failure(let failure):
                    print("Fail", failure)
                    completion(false)
                }
            }
        } catch {
            print("에러",error)
            completion(false)
        }
    }
    //TODO: RxSwift로 변경
    static func createLogin(email: String, password: String, completion: @escaping(Bool)->() ) {
        do {
            let query = LoginQuery(email: email, password: password)
            let request = try Router.login(query: query).asURLRequest()
            AF.request(request).responseDecodable(of: SignModel.self) { response in
                switch response.result {
                case.success(let success):
                    print("OK",success)
                    UserDefaultsManager.shared.token = success.access!
                    UserDefaultsManager.shared.refreshToken = success.refresh!
                    UserDefaultsManager.shared.user_id = success.id
                    //성공적으로 로그인이 되었을 때에만 화면 전환!
                    completion(true)
                case .failure(let failure):
                    print("Fail",failure)
                    completion(false)
                }
            }
        } catch {
            print("에러",error)
            completion(false)
        }
    }
    static func refreshToken() {
        do {
            let request = try Router.refresh.asURLRequest()
            AF.request(request).responseDecodable(of: RefreshModel.self) { responese in
                print(responese.response?.statusCode)
                if responese.response?.statusCode == 418 {
                    for key in UserDefaults.standard.dictionaryRepresentation().keys {
                        UserDefaults.standard.removeObject(forKey: key.description)
                    }
                    let vc = LoginViewController()
                    //self.setRootViewController(vc)
                } else {
                    switch responese.result {
                    case .success(let success):
                        print(success)
                        UserDefaultsManager.shared.token = success.accessToken
                        //self,fetchProfile
                    case.failure(let failure):
                        print(failure)
                    }
                }
            }
        } catch {
            print("에러",error)
        }
    }
}
