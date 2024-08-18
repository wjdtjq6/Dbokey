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
    struct Input {
        let text: ControlProperty<String?>
        let validationTap:  ControlEvent<Void>
        let nextTap: ControlEvent<Void>
    }
    struct Output {
        let validation: Observable<Bool>
        let validationTap:  ControlEvent<Void>
        let nextTap: ControlEvent<Void>
    }
    func transform(input: Input) -> Output {
        //1.
        let validationEmail = input.text.orEmpty
            .map { text in
                text.contains("@") && text.contains(".com")
            }
        input.validationTap
            .withLatestFrom(input.text)
            .debug("체크1")
            .flatMap { value in
                NetworkManager.emailCheck(email: value!).catch { error in
                    print(error.localizedDescription)
                    return Single.just(emailCheckModel(message: "사용할 수 없는 메세지 입니다."))
                }           
            }
            .debug("체크2")
            .subscribe(with: self) { owner, emailCheckModel in
                dump(emailCheckModel.message)
                print("이메일중복확인 결과")
                
            }
        return Output(validation: validationEmail, validationTap: input.validationTap, nextTap: input.nextTap)
    }
}
