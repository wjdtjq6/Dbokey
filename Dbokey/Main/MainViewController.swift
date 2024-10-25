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
    let titleLabel = UILabel().then {
        $0.text = "홈"
        $0.font = .boldSystemFont(ofSize: 30)
    }
    lazy var topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: topLayout())
    lazy var bottomCollectionView = UICollectionView(frame: .zero, collectionViewLayout: bottomLayout())
    let noResultLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.font = .systemFont(ofSize: 20)
        $0.isHidden = true
    }
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    var postDetailData: [PostData] = []
    var category = ""
    let loadMoreTrigger = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
        setupPagination()
    }
    func setupPagination() {
            bottomCollectionView.rx.contentOffset
                .filter { [weak self] offset in
                    guard let self = self else { return false }
                    let contentHeight = self.bottomCollectionView.contentSize.height
                    let scrollViewHeight = self.bottomCollectionView.frame.size.height
                    let threshold: CGFloat = 100 // 스크롤이 하단에서 100포인트 떨어졌을 때 로드
                    return offset.y + scrollViewHeight > contentHeight - threshold
                }
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .map { _ in () }
                .bind(to: loadMoreTrigger)
                .disposed(by: disposeBag)
        }
    func bind() {
        let cellLikeButtonTap = PublishSubject<String>()
        let select = topCollectionView.rx.modelSelected(CategoryItem.self)
        
        let input = MainViewModel.Input(select: select, likeTap: cellLikeButtonTap, selectCell: bottomCollectionView.rx.itemSelected, loadMore: loadMoreTrigger.asObservable())
        let output = viewModel.transform(input: input)
        
        // TopCollectionView
        output.categories
            .bind(to: topCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.id, cellType: CategoryCollectionViewCell.self)) { (row, element, cell) in
                cell.CategoryLbel.text = element.title
                cell.CategoryLbel.font = .boldSystemFont(ofSize: 15)
                cell.CategoryLbel.textColor = Constant.Color.accent
            }
            .disposed(by: disposeBag)
        
        // 선택된 카테고리 제목을 사용
        output.selectedCategoryTitle
            .subscribe(onNext: { [weak self] title in
                self?.category = title
            })
            .disposed(by: disposeBag)
        
        // BottomCollectionView
        output.list
            .subscribe(with: self, onNext: { owner, data in
                owner.postDetailData = data
                if data.isEmpty {
                    owner.noResultLabel.isHidden = false
                    owner.bottomCollectionView.isHidden = true
                } else {
                    owner.noResultLabel.isHidden = true
                    owner.bottomCollectionView.isHidden = false
                    owner.bottomCollectionView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        output.list
           // .map({ $0.data })//예는 [PostData]
            .bind(to: bottomCollectionView.rx.items(cellIdentifier: ListCollectionViewCell.id, cellType: ListCollectionViewCell.self)) { (row, element, cell) in
                cell.titleLabel.text = self.postDetailData[row].title
                cell.location.text = self.postDetailData[row].content2
                cell.price.text = self.postDetailData[row].price.formatted() + "원"//Int(self.postDetailData[row].content2)?.formatted()//(Int(element.content2!)?.formatted())! + "원"
                
                if let urlString = self.postDetailData[row].files.first, let url = URL(string: APIKey.BaseURL+"v1/"+urlString!) {//element.files.first, let url = URL(string: APIKey.BaseURL+"v1/" + urlString!) {
                    let modifier = AnyModifier { request in
                        var request = request
                        request.setValue(APIKey.SesacKey, forHTTPHeaderField: "SesacKey")
                        request.setValue(UserDefaultsManager.shared.token, forHTTPHeaderField: "Authorization")
                        return request
                    }
                    cell.imageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
                }
                cell.soldOut.isHidden = self.postDetailData[row].likes2.isEmpty ? true : false//element.likes2.isEmpty ?  true : false

                cell.likeFuncButton.isSelected = self.postDetailData[row].likes.contains(UserDefaultsManager.shared.user_id)//element.likes.contains(UserDefaultsManager.shared.user_id)
    //                print(cell.likeFuncButton.isSelected,"셀렉됐냐????")
    //                print(element.likes.contains(UserDefaultsManager.shared.user_id),"마포대교는 문어졌냐")
                cell.likeFuncButton.rx.tap
                    .subscribe(with: self) { owner, _
                        in
                        cellLikeButtonTap.onNext(self.postDetailData[row].post_id)//element.post_id)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        //화면 전환
        output.selectCell
            .bind(with: self) { owner, indexPath in
                let vc = DetailViewController()
                vc.mode = .withoutButton
                vc.data = self.postDetailData
                vc.row = indexPath.row
                vc.category = self.category
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)    }
    
    func topLayout() -> UICollectionViewFlowLayout {
        var layout = UICollectionViewFlowLayout()
        //layout.itemSize = CGSize(width: category + 20, height: 50)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 30, right: 30)
        layout.minimumLineSpacing = 30
        //layout.minimumInteritemSpacing = 100
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
    func bottomLayout() -> UICollectionViewFlowLayout {
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
            make.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(30)
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
        navigationItem.backButtonTitle = ""
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(barButtonCliecked))
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.tintColor = Constant.Color.accent
        
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .always
//        navigationItem.title = "홈"
        titleLabel
        let leftBarButton = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftBarButton
        
        topCollectionView.showsHorizontalScrollIndicator = false
        

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
