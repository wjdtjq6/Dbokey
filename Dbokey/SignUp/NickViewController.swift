//
//  NickViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class NickViewController: UIViewController {
   
    let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let descriptionLabel = UILabel()
    //let validText = Observable.just("특수문자(`,~,$,^,+,=,|),숫자,공백을 제외하고 6자 이하로 입력해주세요")
    let disposeBag = DisposeBag()
    let viewModel = NickViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        configureLayout()
       
        bind()
        
    }
    
    func bind() {
        let input = NickViewModel.Input(text: nicknameTextField.rx.text, tap: nextButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        /*let validation = nicknameTextField.rx.text.orEmpty//input
            .map { text in
                text.count >= 2 && text.count < 6 && text.filter{ $0.isNumber }.isEmpty && text.filter{ $0.isSymbol }.isEmpty && text.filter{ $0.isWhitespace }.isEmpty
            }*/
        output.validation//validation
            .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        output.validation//validation
            .bind(with: self) { owner, value in
                owner.nextButton.isEnabled = value
                owner.descriptionLabel.isHidden = value
                let color: UIColor = value ? Constant.Color.accent : Constant.Color.grey
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        output.validText//validText
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        output.tap//nextButton.rx.tap//input,output
            .bind(with: self) { owner, value in
                owner.navigationController?.pushViewController(PhoneNumViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(nicknameTextField)
        view.addSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        view.addSubview(nextButton)
        nicknameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(15)
            make.top.equalTo(nicknameTextField.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(descriptionLabel.snp.bottom)//.offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
