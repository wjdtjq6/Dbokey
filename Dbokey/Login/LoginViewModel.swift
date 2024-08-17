//
//  LoginViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewModel: UIView {
    let account = [
        "zk800@naver.com":"1234",
        "zk800@gmail.com":"th1234"
    ]
    let disposeBag = DisposeBag()
    struct Input {
        let textEmail:  ControlProperty<String?>
        let textPW:  ControlProperty<String?>
        let tap: ControlEvent<Void>
    }
    struct Output {
        let emailRelay: BehaviorRelay<String>
        let passwordRelay: BehaviorRelay<String>
        
        let tap: ControlEvent<Void>
        
        let validationEmail: Observable<Bool>
        let validationPW: Observable<Bool>
    }
    func transform(input: Input) -> Output {
        let emailRelay = BehaviorRelay(value: "")
        let passwordRelay = BehaviorRelay(value: "")
        
        let validationEmail = input.textEmail
            .orEmpty
            .map { $0.count > 0 }

        input.textEmail.orEmpty
            .bind(to: emailRelay)
            .disposed(by: disposeBag)
        
        let validationPW = input.textPW
            .orEmpty
            .map { $0.count > 0 }

        input.textPW.orEmpty
            .bind(to: passwordRelay)
            .disposed(by: disposeBag)
        
        
        return Output(emailRelay: emailRelay, passwordRelay: passwordRelay, tap: input.tap, validationEmail: validationEmail, validationPW: validationPW)
    }
}
