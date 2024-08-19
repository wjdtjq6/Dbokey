//
//  CategoryCollectionViewCell.swift
//  Dbokey
//
//  Created by 소정섭 on 8/19/24.
//

import UIKit
import Then
import SnapKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let id = "CategoryCollectionViewCell"

    let CategoryButton = UIButton().then {
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    func configureHierarchy() {
        contentView.addSubview(CategoryButton)
    }
    func configureLayout() {
        CategoryButton.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
