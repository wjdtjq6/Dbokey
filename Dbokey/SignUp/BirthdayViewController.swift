//
//  BirthdayViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10
        return stack
    }()
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = UIColor.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = UIColor.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    let dayLabel: UILabel = {
    let label = UILabel()
    label.text = "99일"
    label.textColor = UIColor.black
    label.snp.makeConstraints {
        $0.width.equalTo(100)
    }
    return label
}()
    let nextButton = PointButton(title: "가입하기")
    
    var year = BehaviorRelay(value: 1996)
    var month = BehaviorRelay(value: 6)
    var day = BehaviorRelay(value: 1)
    let nColor = Observable.just(UIColor.black)
    let disposeBag = DisposeBag()
    let viewModel = BirthdayViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureLayout()
        bind()
    }
    func bind() {
        let input = BirthdayViewModel.Input(birthday: birthDayPicker.rx.date, tap: nextButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.year
            .map { "\($0)년" }
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        output.month
            .map{ "\($0)월" }
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        output.day
            .map{ "\($0)일" }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        //2,3.
        input.birthday//birthDayPicker.rx.date//input
            .bind(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.day,.month,.year], from: date)
                owner.year.accept(component.year!)
                owner.month.accept(component.month!)
                owner.day.accept(component.day!)
            }
            .disposed(by: disposeBag)
        output.validation//validation
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        output.validation//validation
            .bind(with: self) { owner, value in
                let labelColor: UIColor = value ? .black : .systemRed
                owner.infoLabel.textColor = labelColor
                let labelText: String = value ? "가입 가능한 나이입니다" : "만 17세 이상만 가입 가능합니다."
                owner.infoLabel.text = labelText
                
                let buttonColor: UIColor = value ? .black : .lightGray
                owner.nextButton.backgroundColor = buttonColor
            }
            .disposed(by: disposeBag)
        //4.
        output.tap//nextButton.rx.tap//input,output
            .bind(with: self) { owner, _ in
                let alert = UIAlertController(title: "회원가입 완료", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default) { _ in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd"
                    let pickedDate = dateFormatter.string(from: self.birthDayPicker.date)
                    UserDefaultsManager.shared.birthDay = pickedDate
                    NetworkManager.createJoin(email: UserDefaultsManager.shared.email, passwrod: UserDefaultsManager.shared.password, nick: UserDefaultsManager.shared.nick, phoneNum: UserDefaultsManager.shared.phoneNum, birthDay: UserDefaultsManager.shared.birthDay) { success in
                        if success {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
    }
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)//offset 추가함
            $0.centerX.equalToSuperview().offset(30)
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}
