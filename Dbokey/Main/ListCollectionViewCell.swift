//
//  ListCollectionView.swift
//  Dbokey
//
//  Created by 소정섭 on 8/19/24.
//

import UIKit
import Then
import SnapKit

class ListCollectionViewCell: UICollectionViewCell {
    static let id = "ListCollectionViewCell"
    let imageView = UIImageView().then { _ in
    }
    let likesButton = UIButton().then {
        $0.imageView?.contentMode = .scaleAspectFit
        $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 0)
        $0.tintColor = .systemYellow
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .systemFont(ofSize: 10)
        $0.titleLabel?.text = "ASdasd"
    }
    let likeFuncButton = UIButton().then { _ in
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        contentView.backgroundColor = .lightGray
    }
    func configureHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(likesButton)
        contentView.addSubview(likeFuncButton)
    }
    func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
        likesButton.snp.makeConstraints { make in
            make.bottom.leading.equalTo(contentView.safeAreaLayoutGuide).inset(10)
        }
        likeFuncButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.size.equalTo(25)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
