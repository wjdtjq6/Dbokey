//
//  LoginViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let signInButton = PointButton(title: "로그인")
    let signUpButton = UIButton()
    let messages = ["로그인 성공!","이메일 또는 비밀번호가 잘못되었습니다."]
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureLayout()
        configure()
        bind()
    }
    func bind() {
        let input = LoginViewModel.Input(textEmail: emailTextField.rx.text, textPW: passwordTextField.rx.text, tap: signInButton.rx.tap)
        let output = viewModel.transform(input: input)

        Observable.combineLatest(output.validationEmail, output.validationPW) { $0 && $1 }//ouput
            .bind(with: self, onNext: { owner, value in
                owner.signInButton.isEnabled = value
                let color: UIColor = value ? .black : .lightGray
                owner.signInButton.backgroundColor = color
            })
            .disposed(by: disposeBag)
        
        output.tap//signInButton.rx.tap//input,output
            .bind(onNext: { _ in
                let email = output.emailRelay.value//.value
                let pw = output.passwordRelay.value

                NetworkManager.createLogin(email: email, password: pw) { success in
                    success ? self.showAlert(message: self.messages[0]) : self.showAlert(message: self.messages[1])
                    
                }
            })
            .disposed(by: disposeBag)
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let check = UIAlertAction(title: "확인", style: .default) { _ in
            if alert.title == self.messages[0] {
                let vc = TabBarController()
                //let nav = UINavigationController(rootViewController: vc)
                self.setController(vc)
            }
        }
        alert.addAction(check)
        present(alert, animated: true)
    }
    @objc func signUpButtonPressed() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
        print(#function)
    }
    func configure() {
        signUpButton.setTitle("회원가입하러가기", for: .normal)
        signUpButton.setTitleColor(UIColor.black, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
    }
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(signInButton.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
}

