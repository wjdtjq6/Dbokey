//
//  ProfileView.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import UIKit
import SnapKit

final class ProfileView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "사용자 이름"
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "user@example.com"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .grey
        return label
    }()
    
    let userNameTextField: UITextField = {
        let label = UITextField()
        label.placeholder = "닉네임 변경"
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    let numberTextField: UITextField = {
        let label = UITextField()
        label.placeholder = "010-1234-1234"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .grey
        return label
    }()

    let EditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("프로필 수정", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(userNameLabel)
        addSubview(emailLabel)
        addSubview(numberTextField)
        addSubview(userNameTextField)
        addSubview(EditButton)
        addSubview(logoutButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        userNameTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        numberTextField.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        EditButton.snp.makeConstraints { make in
            make.top.equalTo(numberTextField.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(EditButton.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
    }
}
