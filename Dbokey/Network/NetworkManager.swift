//
//  NetworkManager.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation
import Alamofire

struct NetworkManager {
    private init() {}
    static func createJoin(email: String, passwrod: String, nick: String, phoneNum: String, birthDay: String, completion: @escaping(Bool)->() ) {
        do {
            let query = JoinQuery(email: email, password: passwrod, nick: nick, phoneNum: phoneNum, birthDay: birthDay)
            let request = try Router.join(query: query).asURLRequest()
            AF.request(request).responseDecodable(of: JoinModel.self) { response in
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
            AF.request(request).responseDecodable(of: LoginModel.self) { response in
                switch response.result {
                case.success(let success):
                    print("OK",success)
                    UserDefaultsManager.shared.token = success.access
                    UserDefaultsManager.shared.refreshToken = success.refresh
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
            print("error catch")
        }
    }
}
