//
//  SignUpViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
/*
 1.@,.com을 포함해야함
 2.만족하면 중복확인 isenabled, 중복확인버튼블루
 3.중복확인을 눌러서 확인을 누르면 다음버튼블루,isenabled true
 4.다음버튼누르면 다음페이지로
 5.이메일을 변경하면 다시 처음으로
 */
class SignUpViewController: UIViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let validationButton = UIButton()
    let nextButton = PointButton(title: "다음")
    let disposeBag = DisposeBag()
    let viewModel = SignUpViewModel()
    let messages = ["사용가능한 이메일입니다.","사용할 수 없는 이메일입니다."]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureLayout()
        configure()
        bind()
    }
    func bind() {
        let input = SignUpViewModel.Input.init(text: emailTextField.rx.text, validationTap: validationButton.rx.tap, nextTap: nextButton.rx.tap)
        let output = viewModel.transform(input: input)
        //2.
        output.validation//validation
            .bind(with: self) { owner, value in
                owner.validationButton.isEnabled = value
                let bgColor: UIColor = value ? .black : .lightGray
                owner.validationButton.backgroundColor = bgColor
                owner.validationButton.setTitleColor(.white, for: .normal)
            }
            .disposed(by: disposeBag)
        //3.
        output.validationTap//validationButton.rx.tap//input,output
            .bind { _ in
                NetworkManager.emailCheck(email: self.emailTextField.text!) { success in
                    success ? self.showAlert(message: self.messages[0]) : self.showAlert(message: self.messages[1])
                }
            }
            .disposed(by: disposeBag)
        //4.
        output.nextTap//nextButton.rx.tap//input,output
            .bind(with: self) { owner, _ in
                UserDefaultsManager.shared.email = owner.emailTextField.text!
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        //5.
        output.validation//validation//output
            .bind(with: self) { owner, _ in
                owner.nextButton.isEnabled = false
                owner.nextButton.backgroundColor = .lightGray
            }
            .disposed(by: disposeBag)
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let check = UIAlertAction(title: "확인", style: .default) { _ in
            if alert.title == self.messages[0] {
                self.nextButton.isEnabled = true
                self.nextButton.backgroundColor = .black
                self.nextButton.setTitleColor(.white, for: .normal)
            }
        }
        alert.addAction(check)
        present(alert, animated: true)
    }
    func configure() {
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(UIColor.black, for: .normal)
        validationButton.layer.cornerRadius = 10
    }
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}
