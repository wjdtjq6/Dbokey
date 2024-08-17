//
//  PasswordViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/17/24.
//

import Foundation
import RxSwift
import RxCocoa

class PasswordViewModel {
    struct Input {
        let text: ControlProperty<String?>
        let tap: ControlEvent<Void>
    }
    struct Output {
        let validation: Observable<Bool>
        let validText: Observable<String>
        let tap: ControlEvent<Void>
    }
    func transform(input: Input) -> Output {
        //1.
        let validation = input.text.orEmpty//input
            .map { $0.count >= 8 }
        let validText = Observable.just("8자 이상 입력해주세요")

        return Output(validation: validation, validText: validText, tap: input.tap)
    }
}
