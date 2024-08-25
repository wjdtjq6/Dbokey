//
//  CommentTableViewCell.swift
//  Dbokey
//
//  Created by 소정섭 on 8/25/24.
//

import UIKit
import SnapKit

class CommentTableViewCell: UITableViewCell {
    static let identifier = "CommentTableViewCell"
    let nickLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 15)
    }
    let commentLabel = UILabel().then { _ in
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nickLabel)
        contentView.addSubview(commentLabel)
        nickLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(5)
            make.leading.equalTo(contentView)//.offset(5)
        }
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(5)
            make.leading.equalTo(nickLabel.snp.trailing).offset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
