//
//  PasswordViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
/*
 1. 8자 이상 true
 2. 버튼 isEnabled false
 3. descriptionLabel
 4. 맞으면 없어지고, 버튼isEnabled true
 5. 뷰 넘기기
 */
class PasswordViewController: UIViewController {
    
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let descriptionLabel = UILabel()
    
    let disposeBag = DisposeBag()
    let viewModel = PasswordViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureLayout()
        bind()
    }
    func bind() {
        let input = PasswordViewModel.Input.init(text: passwordTextField.rx.text, tap: nextButton.rx.tap)
        let output = viewModel.transform(input: input)
        //2.
        output.validation//validation//output
            .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        //3.
        output.validText//validText//output
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        //4.
        output.validation//validation//output
            .bind(with: self) { owner, value in
                owner.nextButton.isEnabled = value
                owner.descriptionLabel.isHidden = value
                let color: UIColor = value ? Constant.Color.accent : Constant.Color.grey
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        //5.
        output.tap//nextButton.rx.tap//input,output
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(NickViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
        view.addSubview(descriptionLabel)
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(passwordTextField.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(descriptionLabel.snp.bottom)//.offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

