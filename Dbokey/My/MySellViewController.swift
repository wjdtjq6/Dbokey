//
//  MySellViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/30/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class MySellViewController: UIViewController {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    let noResultLabel = UILabel().then {
        $0.text = "판매 중인 상품이 없습니다."
        $0.font = .systemFont(ofSize: 20)
        $0.isHidden = true
    }
    let viewModel = MySellViewModel()
    let disposeBag = DisposeBag()
    var postDetailData: [PostData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }

    func bind() {
        let cellLikeButtonTap = PublishSubject<String>()

        let input = MySellViewModel.Input(likeTap: cellLikeButtonTap, selectCell: collectionView.rx.itemSelected)
        let output = viewModel.transform(input: input)

        output.list
            .subscribe(with: self, onNext: { owner, data in
                owner.postDetailData = data
                if data.isEmpty {
                    owner.noResultLabel.isHidden = false
                    owner.collectionView.isHidden = true
                } else {
                    owner.noResultLabel.isHidden = true
                    owner.collectionView.isHidden = false
                    owner.collectionView.reloadData()
                }
            })
            .disposed(by: disposeBag)

        output.list
            .bind(to: collectionView.rx.items(cellIdentifier: ListCollectionViewCell.id, cellType: ListCollectionViewCell.self)) { (row, element, cell) in
                cell.titleLabel.text = self.postDetailData[row].title
                cell.location.text = self.postDetailData[row].content2
                cell.price.text = self.postDetailData[row].price.formatted() + "원"

                if let urlString = self.postDetailData[row].files.first, let url = URL(string: APIKey.BaseURL+"v1/"+urlString!) {
                    let modifier = AnyModifier { request in
                        var request = request
                        request.setValue(APIKey.SesacKey, forHTTPHeaderField: "SesacKey")
                        request.setValue(UserDefaultsManager.shared.token, forHTTPHeaderField: "Authorization")
                        return request
                    }
                    cell.imageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
                }
                cell.soldOut.isHidden = self.postDetailData[row].likes2.isEmpty ? true : false

                cell.likeFuncButton.isSelected = self.postDetailData[row].likes.contains(UserDefaultsManager.shared.user_id)
                cell.likeFuncButton.rx.tap
                    .subscribe(with: self) { owner, _ in
                        cellLikeButtonTap.onNext(self.postDetailData[row].post_id)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)

        output.selectCell
            .bind(with: self) { owner, indexPath in
                let vc = DetailViewController()
                vc.mode = .withButton
                vc.data = self.postDetailData
                vc.row = indexPath.row
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }

    static func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 15
        layout.itemSize = CGSize(width: width/2, height: 260)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }

    func configureHierarchy() {
        view.addSubview(collectionView)
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        view.addSubview(noResultLabel)
    }

    func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        noResultLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "내 판매 목록"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = Constant.Color.accent
    }
}
