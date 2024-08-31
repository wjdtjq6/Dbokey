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
    var postDetailData: [PostData] = []
    var category = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    func bind() {
        bindTopCollectionView()
        bindBottomCollectionView()
        bindLoadMoreData()
        handleSelectCell()
    }

    private func bindTopCollectionView() {
        // TopCollectionView
        output.categories
            .bind(to: topCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.id, cellType: CategoryCollectionViewCell.self)) { (row, element, cell) in
                cell.CategoryLbel.text = element.title
            }
            .disposed(by: disposeBag)

        output.selectedCategoryTitle
            .subscribe(onNext: { [weak self] title in
                self?.category = title
            })
            .disposed(by: disposeBag)
    }

    private func bindBottomCollectionView() {
        output.list
            .subscribe(with: self, onNext: { owner, data in
                owner.postDetailData = data
                owner.updateBottomCollectionView(data.isEmpty)
            })
            .disposed(by: disposeBag)
    }

    private func bindLoadMoreData() {
        bottomCollectionView.rx.contentOffset
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .map { [weak self] offset -> Bool in
                guard let self = self else { return false }
                return self.shouldLoadMoreData(offset: offset)
            }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.loadMoreData()
            })
            .disposed(by: disposeBag)
    }

    private func updateBottomCollectionView(_ isEmpty: Bool) {
        noResultLabel.isHidden = !isEmpty
        bottomCollectionView.isHidden = isEmpty
        if !isEmpty {
            bottomCollectionView.reloadData()
        }
    }

    private func handleSelectCell() {
        output.selectCell
            .bind(with: self) { owner, indexPath in
                let vc = DetailViewController()
                vc.mode = .withoutButton
                vc.data = owner.postDetailData
                vc.row = indexPath.row
                vc.category = owner.category
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }

    private func shouldLoadMoreData(offset: CGPoint) -> Bool {
        let visibleHeight = bottomCollectionView.frame.height
        let contentHeight = bottomCollectionView.contentSize.height
        let yOffset = offset.y
        let threshold = contentHeight - visibleHeight - 100
        return yOffset > threshold
    }

    static func topLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 85, height: 50)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
    static func bottomLayout() -> UICollectionViewFlowLayout {
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
        noResultLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(barButtonCliecked))
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.tintColor = .black
        navigationItem.backButtonTitle = ""

    }
    @objc func barButtonCliecked() {
        print(#function)
        let vc = WriteViewController()
        vc.mode = .writeMode
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
