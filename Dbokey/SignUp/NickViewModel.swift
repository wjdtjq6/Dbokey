//
//  NickViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/17/24.
//

import Foundation
import RxSwift
import RxCocoa

class NickViewModel {
    struct Input {
        let text: ControlProperty<String?>
        let tap: ControlEvent<Void>
    }
    struct Output {
        let tap: ControlEvent<Void>
        let validText: Observable<String>
        let validation: Observable<Bool>
    }
    func transform(input: Input) -> Output {
        let validation = input.text
            .orEmpty
            .map { text in
                text.count >= 2 && text.count < 6 && text.filter{ $0.isNumber }.isEmpty && text.filter{ $0.isSymbol }.isEmpty && text.filter{ $0.isWhitespace }.isEmpty
            }
        let validText = Observable.just("특수문자(`,~,$,^,+,=,|),숫자,공백을 제외하고 6자 이하로 입력해주세요")
        
        return Output(tap: input.tap, validText: validText, validation: validation)
    }
}
