//
//  ViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/14/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class MainViewController: UIViewController {
    let topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: topLayout())
    let bottomCollectionView = UICollectionView(frame: .zero, collectionViewLayout: bottomLayout())
    let noResultLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.font = .systemFont(ofSize: 20)
        $0.isHidden = true
    }
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    func bind() {
        let cellLikeButtonTap = PublishSubject<String>() // (postID, currentLikeStatus)
        let select = topCollectionView.rx.modelSelected(Category.self)

        let input = MainViewModel.Input(select: select, likeTap: cellLikeButtonTap)
        let output = viewModel.transform(input: input)
        
        // TopCollectionView
        output.categories
            .bind(to: topCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.id, cellType: CategoryCollectionViewCell.self)) { (row, element, cell) in
                cell.CategoryLbel.text = "\(element.title)"
            }
            .disposed(by: disposeBag)
        
        // BottomCollectionView
        output.list
            .map({ $0.data })
            .bind(to: bottomCollectionView.rx.items(cellIdentifier: ListCollectionViewCell.id, cellType: ListCollectionViewCell.self)) { (row, element, cell) in
                cell.titleLabel.text = element.title
                cell.location.text = element.content3
                cell.price.text = (Int(element.content2!)?.formatted())! + "원"
                
                if let urlString = element.files.first, let url = URL(string: APIKey.BaseURL+"v1/" + urlString!) {
                    let modifier = AnyModifier { request in
                        var request = request
                        request.setValue(APIKey.SesacKey, forHTTPHeaderField: "SesacKey")
                        request.setValue(UserDefaultsManager.shared.token, forHTTPHeaderField: "Authorization")
                        return request
                    }
                    cell.imageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
                }
                
                cell.likeFuncButton.isSelected = element.likes.contains(UserDefaultsManager.shared.user_id)
                
                cell.likeFuncButton.rx.tap
                    .subscribe(with: self) { owner, _
                        in
                        cellLikeButtonTap.onNext(element.post_id)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.soldOut.isHidden = element.likes2.isEmpty ?  true : false
            }
            .disposed(by: disposeBag)
    }

    static func topLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 85, height: 50)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return layout
    }
    static func bottomLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 15
        layout.itemSize = CGSize(width: width/2, height: 250)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }
    func configureHierarchy() {
        view.addSubview(topCollectionView)
        view.addSubview(bottomCollectionView)
        topCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.id)
        bottomCollectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        view.addSubview(noResultLabel)
        //bottomCollectionView.prefetchDataSource = self//pagenation
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
}/*
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.id, for: indexPath) as! CategoryCollectionViewCell
            cell.CategoryLbel.text = categories[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as! ListCollectionViewCell
            return cell
        }
    }
}
*/
