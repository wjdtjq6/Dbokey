//
//  DetailViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/24/24.
//

import UIKit
import Then
import SnapKit
import Kingfisher
class DetailViewController: UIViewController {
    var data: PostData?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    func configureHierarchy() {
        
    }
    func configureLayout() {
        
    }
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = data?.title
    }
}
