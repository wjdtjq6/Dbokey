//
//  MySellViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/30/24.
//

import UIKit
import SnapKit
import Then

class MySellViewController: UIViewController {
//    let CollectionView = UICollectionView(frame: .zero, collectionViewLayout: Layout())
    let noResultLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.font = .systemFont(ofSize: 20)
        $0.isHidden = true
    }
}
