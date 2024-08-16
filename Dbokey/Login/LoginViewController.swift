//
//  LoginViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import UIKit

final class LoginViewController: UIViewController {
    private let loginView = LoginView()
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        loginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        loginView.signButton.addTarget(self, action: #selector(signButtonTapped), for: .touchUpInside)
    }
    //이메일/비밀번호 유효성 잘못되었을 경우 > 서버통신을 거치지 않고 얼럿
    //이메일/비밀번호 잘 입력한 경우에만 서버통신 진행!
    @objc private func loginButtonTapped() {
        NetworkManager.createLogin(email: loginView.emailTextField.text!, password: loginView.passwordTextField.text!) { (success) in
            if success {
                let vc = ProfileViewController()
                self.setRootViewController(vc)
            }
        }
    }
    
    @objc private func signButtonTapped() {
//        let signUpVC = SignUpViewController()
//        present(signUpVC, animated: true)
    }
}

