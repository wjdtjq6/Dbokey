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
        let request = try! Router.likePost(query: query, postID: postID).asURLRequest()
        print("Request Body: \(request.httpBody?.base64EncodedString())")
        AF.request(request)
            .validate(statusCode: 200...299)
            .responseDecodable(of: likeModel.self) { response in
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

    /*
    static func likePost(postID: String, like_status: Bool) ->Observable<likeModel> {
        let query = likePostQuery(like_status: like_status)
        let request = try! Router.likePost(query: query, postID: postID).asURLRequest()
        print("Request Body: \(request.httpBody?.base64EncodedString())")
        return Observable.create { observer in
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseDecodable(of: likeModel.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer.onNext(success)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }.debug("likePost API 통신")
    }
     */
    static func viewPost(next: String, limit: String, productID: String) -> Single<ViewPostModel> {
        //let query = ViewPostQuery(next: next,limit: limit, product_id: productID)
        let request = try! Router.viewPost(next: next, limit: limit, productID: productID).asURLRequest()
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
