//
//  BirthdayViewModel.swift
//  Dbokey
//
//  Created by 소정섭 on 8/17/24.
//

import Foundation
import RxSwift
import RxCocoa

class BirthdayViewModel {
    struct Input {
        let birthday: ControlProperty<Date>
        let tap: ControlEvent<Void>
    }
    struct Output {
        let year: Observable<Int>
        let month: Observable<Int>
        let day: Observable<Int>
        let validation: Observable<Bool>
        let tap: Observable<Void>
    }
    func transform(input: Input) -> Output {
        let year = input.birthday
            .map { Calendar.current.component(.year, from: $0) }
        
        let month = input.birthday
            .map { Calendar.current.component(.month, from: $0) }
        
        let day = input.birthday
            .map { Calendar.current.component(.day, from: $0) }
        
        let validation = input.birthday
            .map { date -> Bool in
                let calendar = Calendar.current
                let now = Date()
                let ageComponents = calendar.dateComponents([.year], from: date, to: now)
                return (ageComponents.year ?? 0) >= 17
            }
            .distinctUntilChanged()
        
        return Output(
            year: year.asObservable(),
            month: month.asObservable(),
            day: day.asObservable(),
            validation: validation,
            tap: input.tap.asObservable()
        )
    }
}
