//
//  ListCollectionView.swift
//  Dbokey
//
//  Created by 소정섭 on 8/19/24.
//

import UIKit
import Then
import SnapKit
import RxSwift

class ListCollectionViewCell: UICollectionViewCell {
    static let id = "ListCollectionViewCell"
    let disposeBag = DisposeBag()
    let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.contentMode = .scaleToFill
        //TODO: NVActivityIndicatorView 적용 예정
    }
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.lineBreakMode = .byTruncatingTail // 텍스트가 길어지면 ...으로 표시
        $0.numberOfLines = 1 // 한 줄로 설정
    }
    let location = UILabel().then {
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 13)
    }
    let price = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 15)
    }
    let soldOut = UILabel().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.font = .boldSystemFont(ofSize: 12)
        $0.text = "거래완료"
        $0.textAlignment = .center
        $0.isHidden = true
    }
    let likeFuncButton = UIButton().then {
        $0.setImage(UIImage(systemName: "bookmark"), for: .normal)
        $0.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        $0.tintColor = .white
        $0.transform = CGAffineTransform(scaleX: 2, y: 1.5) // 이미지를 2배로 확대
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    func configureHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(soldOut)
        contentView.addSubview(likeFuncButton)
        contentView.addSubview(location)
        contentView.addSubview(price)
    }
    func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(60)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(4)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(4)
        }
        location.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(4)
        }
        price.snp.makeConstraints { make in
            make.top.equalTo(location.snp.bottom).offset(4)
            make.leading.equalTo(contentView.safeAreaLayoutGuide.snp.leading).offset(4)
        }
        soldOut.snp.makeConstraints { make in
            make.top.equalTo(location.snp.bottom).offset(4)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(4)
            make.width.equalTo(55)
            make.height.equalTo(20)
        }
        likeFuncButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
