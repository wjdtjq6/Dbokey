//
//  CommunityViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/25/24.
//

import UIKit
import SnapKit

class CommunityViewController: UIViewController {
    let imageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        imageView.backgroundColor = .red
    }
}
