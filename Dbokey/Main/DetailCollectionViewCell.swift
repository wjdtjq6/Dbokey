//
//  DetailCollectionViewCell.swift
//  Dbokey
//
//  Created by 소정섭 on 8/25/24.
//

import UIKit
import SnapKit

class DetailCollectionViewCell: UICollectionViewCell {
    static let identifier = "DetailCollectionViewCell"
    let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    func configureHierarchy() {
        contentView.addSubview(imageView)
    }
    func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    func configureUI() {
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
