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
        let cellLikeButtonTap = PublishSubject<String>()
        let select = topCollectionView.rx.modelSelected(CategoryItem.self)
        
        let input = MainViewModel.Input(select: select, likeTap: cellLikeButtonTap, selectCell: bottomCollectionView.rx.itemSelected)
        let output = viewModel.transform(input: input)
        
        // TopCollectionView
        output.categories
            .bind(to: topCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.id, cellType: CategoryCollectionViewCell.self)) { (row, element, cell) in
                cell.CategoryLbel.text = element.title
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
                owner.navigationItem.title = String(data.count)//MARK: here
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
                vc.data = self.postDetailData
                vc.row = indexPath.row
                vc.category = self.category
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)    }
    
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
        noResultLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(barButtonCliecked))
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.tintColor = .black
    }
    @objc func barButtonCliecked() {
        print(#function)
        let vc = WriteViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
//    override func viewWillAppear(_ animated: Bool) {
//      navigationController?.setNavigationBarHidden(true, animated: true)// 뷰 컨트롤러가 나타날 때 숨기기
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//      navigationController?.setNavigationBarHidden(false, animated: true)// 뷰 컨트롤러가 사라질 때 나타내기
//    }
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
