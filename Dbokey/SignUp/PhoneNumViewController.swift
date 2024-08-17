//
//  PhoneNumViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
/*
 1.첫 화면 진입 시 010을 textField에 바로 띄움
 2.textField에는 숫자만 들어갈 수 있고, 10자 이상이어야 함
 3.textField 조건이 맞지 않을 경우, PasswordViewController Logic처럼 처리
 4.조건에 맞아 버튼 누르면 push
 */
class PhoneNumViewController: UIViewController {
   
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let disposeBag = DisposeBag()
    let viewModel = PhoneNumViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureLayout()
        phoneTextField.keyboardType = .numberPad
        bind()
    }

    func bind() {
        let input = PhoneNumViewModel.Input(text: phoneTextField.rx.text, tap: nextButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        //1.
        //let validInt = BehaviorSubject(value: "010")
        //validInt
        output.validInt
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        //2.
       /*let validation = phoneTextField.rx.text.orEmpty//input
            .map { $0.count >= 10 }*/
        //3.
        output.validation
            .bind(with: self, onNext: { owner, value in
                owner.nextButton.isEnabled = value
                let color: UIColor = value ? .black : .lightGray
                owner.nextButton.backgroundColor = color
                
            })
            .disposed(by: disposeBag)
        //4.
        output.tap//nextButton.rx.tap//input,output
            .bind(with: self) { owner, _ in
                UserDefaultsManager.shared.phoneNum = owner.phoneTextField.text!
                owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
