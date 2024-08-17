//
//  PhoneNumViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/17/24.
//

import Foundation
import RxSwift
import RxCocoa

class PhoneNumViewModel {
    struct Input {
        let text: ControlProperty<String?>
        let tap: ControlEvent<Void>
    }
    struct Output {
        let tap: ControlEvent<Void>
        let validation: Observable<Bool>
        let validInt: BehaviorSubject<String>
    }
    func transform(input: Input) -> Output {
        let validation = input.text
            .orEmpty
            .map { $0.count >= 10 }
        let validInt = BehaviorSubject(value: "010")
        
        return Output(tap: input.tap,validation: validation, validInt: validInt)
    }
}
