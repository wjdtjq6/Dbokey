//
//  MyTableViewCell.swift
//  Dbokey
//
//  Created by 소정섭 on 8/29/24.
//

import UIKit
import SnapKit

class MyTableViewCell: UITableViewCell {
    static let identifier = "MyTableViewCell"
    let profileImage = UIImageView()
    let profileLabel = UILabel()
    let profileDateLabel = UILabel()
    let nextImage = UIImageView()
    
    let bagImage = UIImageView()
    let bagListLabel = UILabel()
    let bagListLabel2 = UILabel()
    
    // TODO: EDIT PROFILE갔다가 뒤로 오면 userDefaults가 저장되는데 이미지는 안바뀌어서 바뀌도록
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.textLabel!.text = nil
        self.bagListLabel.text = nil
        self.bagListLabel2.text = nil
        self.bagImage.image = nil
        self.profileImage.image = nil
        self.profileLabel.text = nil
        self.profileDateLabel.text = nil
        self.nextImage.image = nil
        self.profileImage.layer.borderWidth = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImage)
        contentView.addSubview(profileLabel)
        contentView.addSubview(profileDateLabel)
        contentView.addSubview(nextImage)
        
        contentView.addSubview(bagImage)
        contentView.addSubview(bagListLabel)
        contentView.addSubview(bagListLabel2)
            
        profileImage.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = 50
        
        profileLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide).offset(-10)
            make.leading.equalTo(profileImage.snp_trailingMargin).offset(30)
            make.width.equalTo(200)
        }
        profileLabel.font = .boldSystemFont(ofSize: 16)
        
        profileDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(profileImage.snp_trailingMargin).offset(30)
            make.width.equalTo(200)
        }
        profileDateLabel.font = .systemFont(ofSize: 14)
        profileDateLabel.textColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 0.5)
        
        nextImage.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.width.equalTo(10)
        }
        nextImage.tintColor = UIColor(red: 76/255, green: 76/255, blue: 76/255, alpha: 1.0)
        
        bagListLabel2.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
            make.width.equalTo(50)
        }
        bagListLabel2.font = .systemFont(ofSize: 14)
        
        bagListLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(bagListLabel2.snp.leading)
        }
        bagListLabel.font = .boldSystemFont(ofSize: 14)

        bagImage.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(bagListLabel.snp.leading)
            make.width.equalTo(20)
        }
        bagImage.tintColor = Constant.Color.accent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
