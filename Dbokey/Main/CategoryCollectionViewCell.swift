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

    let CategoryLbel = UILabel().then {
        $0.textColor = .accent
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 15)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    func configureHierarchy() {
        contentView.addSubview(CategoryLbel)
    }
    func configureLayout() {
        CategoryLbel.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
