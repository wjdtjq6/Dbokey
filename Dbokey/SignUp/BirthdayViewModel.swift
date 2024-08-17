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
        let year: BehaviorRelay<Int>
        let month: BehaviorRelay<Int>
        let day: BehaviorRelay<Int>
        let tap: ControlEvent<Void>
        let validation: Observable<Bool>
    }
    func transform(input: Input) -> Output {
        //1.
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let yearStr = yearFormatter.string(from: Date.now)
        let year = BehaviorRelay(value: Int(yearStr)!)
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "M"
        let monthStr = monthFormatter.string(from: Date.now)
        let month = BehaviorRelay(value: Int(monthStr)!)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let dayStr = dayFormatter.string(from: Date.now)
        let day = BehaviorRelay(value:Int(dayStr)!)
        
        
        let validation = input.birthday
            .map { date -> Bool in
                let component = Calendar.current.dateComponents([.year], from: date, to: Date())
                guard let age = component.year else { return false }
                return age >= 17
            }
        return Output(year: year, month: month, day: day, tap: input.tap, validation: validation)
    }
}
