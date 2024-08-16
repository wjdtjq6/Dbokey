//
//  ProfileViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import UIKit

final class ProfileViewController: UIViewController {
    private let profileView = ProfileView()

    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfile()
        setupActions()
    }
    private func fetchProfile() {
//        NetworkManager.fetchProfile() { bool,success in
//            print(success)
//            if bool {
//                self.profileView.emailLabel.text = success.email
//                self.profileView.userNameLabel.text = success.nick
//            }
//        }
    }
    private func editProfile() {
//        NetworkManager.editProfile(nick: profileView.userNameTextField.text!, phoneNum: profileView.numberTextField.text!, completion: { bool, success in
//            if bool {
//                success.profile?.base64EncodedString()
////                self.profileView.userNameTextField.text = success.email
////                self.profileView.numberTextField.text = success.nick
//                //or 수정한 내용 한 번 더 체크:
//                self.fetchProfile()
//            }
//        })
    }
    /*func refreshToken() {
        let url = Key.baseURL + "v1/auth/refresh"
        let accessToken = UserDefaults.standard.string(forKey: UserDefaultsKey.access.rawValue) ?? ""
        let refreshToken = UserDefaults.standard.string(forKey: UserDefaultsKey.refresh.rawValue) ?? ""
        let header: HTTPHeaders = [
            Header.authorization.rawValue: accessToken,
            Header.authorization.rawValue: refreshToken,
            Header.contentType.rawValue: Header.json.rawValue,
            Header.sesacKey.rawValue: Key.key
        ]
        AF.request(url,method: .get, headers: header).responseDecodable(of: RefreshModel.self) { response in
            print(response.response?.statusCode)
                if response.response?.statusCode == 418 {
                    for key in UserDefaults.standard.dictionaryRepresentation().keys {
                        UserDefaults.standard.removeObject(forKey: key.description)
                    }
                    let vc = LoginViewController()
                    self.setRootViewController(vc)
                } else {
                    switch response.result {
                    case .success(let success):
                        print(success)
                        UserDefaults.standard.setValue(success.accessToken, forKey: UserDefaultsKey.access.rawValue)
                        self.fetchProfile()//도르마무/ 사용자는 내 accesstoken이 만료됐는지 알수없음
                    case .failure(let failure):
                        print(failure)
                }
            }
        }
    }*/
    private func setupActions() {
        profileView.logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        profileView.EditButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    @objc private func editButtonTapped() {
        editProfile()
    }
    @objc private func logoutButtonTapped() {
        //임시로 로그인 기능 달아놓기
        //로그인해서 엑세스/리프레시 토큰 새롭게 항상 저장
        //게시글 업로드
        
        NetworkManager.createLogin(email: "112233", password: "123") { (success) in
            if success {
                let vc = UINavigationController(rootViewController: LoginViewController())
                //self.setRootViewController(vc)
            }
        }

    }
}
//1.accessToken 갱신 로직 구조화(어떻게 하나로 만들 수 있을까?)
//2.0.5~1초 연속x
//3.multipart/form-data
