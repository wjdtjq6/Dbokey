//
//  ViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/14/24.
//

import UIKit
import Then
import SnapKit

class MainViewController: UIViewController {
    let topCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width =  UIScreen.main.bounds.width - 40
        layout.itemSize = CGSize(width: 85, height: 50)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let object = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return object
    }()
    let bottomCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 15
        layout.itemSize = CGSize(width: width/2, height: 250)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let object = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return object
    }()
    let noResultLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.font = .systemFont(ofSize: 20)
        $0.isHidden = true
    }
    let categories = ["기성품 키보드", "커스텀 키보드", "키캡", "아티산", "스위치", "기타"]
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    func configureHierarchy() {
        view.addSubview(topCollectionView)
        view.addSubview(bottomCollectionView)
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
        topCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.id)
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
        bottomCollectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        view.addSubview(noResultLabel)
        bottomCollectionView.prefetchDataSource = self//pagenation
    }
    func configureLayout() {
        topCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        bottomCollectionView.snp.makeConstraints { make in
            make.top.equalTo(topCollectionView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureUI() {
        view.backgroundColor = .white
    }
}
extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for i in indexPaths {
            //cursor-base pagenation not offset-based pagenation
            
//            if i.row == searchList.results.count-1 && page < searchList.total_pages {
//                page += 1
//                toggleCall()
//            }
        }
    }
}
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topCollectionView {
            return categories.count
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.id, for: indexPath) as! CategoryCollectionViewCell
            cell.CategoryButton.setTitle(categories[indexPath.item], for: .normal)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as! ListCollectionViewCell
            return cell
                
        }
        
    }
    
    
}
