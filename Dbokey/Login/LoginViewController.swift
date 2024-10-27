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
        let input = LoginViewModel.Input(
            textEmail: emailTextField.rx.text,
            textPW: passwordTextField.rx.text,
            tap: signInButton.rx.tap
        )
        let output = viewModel.transform(input: input)

        Observable.combineLatest(output.validationEmail, output.validationPW) { $0 && $1 }
            .bind(with: self, onNext: { owner, value in
                owner.signInButton.isEnabled = value
                let color: UIColor = value ? Constant.Color.accent : Constant.Color.grey
                owner.signInButton.backgroundColor = color
            })
            .disposed(by: disposeBag)
        
        output.tap
            .withLatestFrom(Observable.combineLatest(output.emailRelay, output.passwordRelay))
            .flatMap { [weak self] (email, password) -> Single<SignModel> in
                guard let self = self else {
                    return .error(NetworkError.unknown)
                }
                return NetworkManager.createLogin(email: email, password: password)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                // 토큰 정보 저장
                UserDefaultsManager.shared.token = response.access ?? ""
                UserDefaultsManager.shared.refreshToken = response.refresh ?? ""
                // 사용자 정보 저장
                UserDefaultsManager.shared.user_id = response.id
                UserDefaultsManager.shared.nick = response.nick
                self.showAlert(message: self.messages[0])
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.showAlert(message: self.messages[1])
            })
            .disposed(by: disposeBag)
    }

    // showAlert 메서드도 약간 수정
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let check = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if message == self.messages[0] {
                let vc = TabBarController()
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

