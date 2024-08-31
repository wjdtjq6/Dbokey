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
    
    static func deletePost(post_id: String, completion: @escaping(Bool) -> Void) {
        do {
            let request = try Router.deletePost(postID: post_id).asURLRequest()
            AF.request(request).response() { response in
                switch response.result {
                case .success(let success):
                    print(success)
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }
        } catch {
            print("에러",error)
        }
    }
    static func editPost(post_id: String, title: String, content: String, content1: String, content2: String, content3: String, price: Int, product_id: String, files: [String], completion: @escaping (Result<PostData, Error>) -> Void) {
        let query = writeEditPostQuery(title: title, content: content, content1: content1, content2: content2, content3: content3, price: price, product_id: product_id, files: files)
        var request = try! Router.editPost(query: query, postID: post_id).asURLRequest()
        print("Request Body: \(request.httpBody?.base64EncodedString())")
        AF.request(request)
            .validate(statusCode: 200...299)
            .responseDecodable(of: PostData.self) { response in
                print("statusCode", response.response?.statusCode)
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    static func usersPost(userID: String, next: String, limit: String) -> Single<ViewPostModel> {
       return Single.create { observer in
           do {
               var request = try Router.usersPost(userID: userID, next: next, limit: limit).asURLRequest()

               if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                   urlComponents.queryItems = Router.usersPost(userID: userID, next: next, limit: limit).queryItems
                   request.url = urlComponents.url
               }

               print("Complete URL: \(request.url?.absoluteString ?? "Invalid URL")")

               AF.request(request)
                   .validate(statusCode: 200...299)
                   .responseDecodable(of: ViewPostModel.self) { response in
                       switch response.result {
                       case .success(let value):
                           observer(.success(value))
                       case .failure(let error):
                           observer(.failure(error))
                       }
                   }
           } catch {
               observer(.failure(error))
           }
           return Disposables.create()
       }
   }
    static func withdraw() {
        do {
            let request = try Router.withdraw.asURLRequest()
            AF.request(request).responseDecodable(of: SignModel.self) { response in
                print(response.response?.statusCode)
                switch response.result {
                case .success(let success):
                    print(success)
                case .failure(let error):
                    print(error)
                }
            }
        } catch {
            print("에러",error)
        }
    }
    static func uploadFiles(images: [Data?], completion: @escaping (Result<uploadFilesModel, Error>) -> Void) {
        let url = APIKey.BaseURL + "v1/posts/files"
        
        let token = UserDefaultsManager.shared.token
        
        let header:HTTPHeaders = [
            Header.sesacKey.rawValue: APIKey.SesacKey,
            Header.authorization.rawValue: token,
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
            if response.response?.statusCode == 400 {
                // 400 에러일 때, completion을 통해 에러 전달
                completion(.failure(NSError(domain: "NetworkError", code: 400, userInfo: [NSLocalizedDescriptionKey: "요청이 잘못되었습니다. 다시 시도해 주세요."])))
            } else {
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    static func uploadPostContents(title: String, content: String, content1: String, content2: String, content3: String, price: Int, product_id: String, files: [String], completion: @escaping (Result<PostData, Error>) -> Void) {
        print(#function)
        let query = writeEditPostQuery(title: title, content: content, content1: content1, content2: content2, content3: content3, price: price, product_id: product_id, files: files)
        var request = try! Router.writePost(query: query).asURLRequest()
        print("Request Body: \(request.httpBody?.base64EncodedString())")
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseDecodable(of: PostData.self) { response in
                    print("statusCode", response.response?.statusCode)
                    switch response.result {
                    case .success(let value):
                        completion(.success(value))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }   
    }
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
                    UserDefaultsManager.shared.nick = success.nick
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
