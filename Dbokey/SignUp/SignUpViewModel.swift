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
        return Output(validation: validationEmail, validationTap: input.validationTap, nextTap: input.nextTap)
    }
}
