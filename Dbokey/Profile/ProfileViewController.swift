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
    private func setupActions() {
        profileView.logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        profileView.EditButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    @objc private func editButtonTapped() {
        editProfile()
    }
    @objc private func logoutButtonTapped() {
        let vc = UINavigationController(rootViewController: LoginViewController())
        self.setController(vc)
    }
}
