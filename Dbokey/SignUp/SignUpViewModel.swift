//
//  SignUpViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation
import RxSwift
import RxCocoa

class SignUpViewModel {
    let disposeBag = DisposeBag()
    struct Input {
        let text: ControlProperty<String?>
        let validationTap:  ControlEvent<Void>
        let nextTap: ControlEvent<Void>
    }
    struct Output {
        let validation: Observable<Bool>
        let validationTap:  ControlEvent<Void>
        let nextTap: ControlEvent<Void>
        let emailCheckResult: Observable<String>
    }
    func transform(input: Input) -> Output {
        let validationEmail = input.text.orEmpty
            .map { text in
                text.contains("@") && text.contains(".com")
            }
        let emailCheckResult = input.validationTap
            .withLatestFrom(input.text.orEmpty)
            .debug("체크1")
            .flatMapLatest({ email in
                NetworkManager.emailCheck(email: email)
                    .catch { error in
                    print(error.localizedDescription)
                    return Single.just(EmailCheckModel(message: "사용할 수 없는 이메일입니다."))
                }
                .map { $0.message }
            })
            .debug("체크2")

        return Output(validation: validationEmail, validationTap: input.validationTap, nextTap: input.nextTap, emailCheckResult: emailCheckResult)
    }
}
