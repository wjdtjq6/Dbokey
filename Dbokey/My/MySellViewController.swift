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
    
    // MARK: - Properties
    private let tableView = UITableView().then {
        $0.backgroundColor = .systemBackground
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 140
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    private let noResultView = UIView().then {
        $0.isHidden = true
    }
    
    private let noResultImageView = UIImageView().then {
        $0.image = UIImage(systemName: "cart.badge.questionmark")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemGray3
    }
    
    private let noResultLabel = UILabel().then {
        $0.text = "판매 중인 상품이 없습니다."
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .systemGray2
        $0.textAlignment = .center
    }
    
    private let noResultDescriptionLabel = UILabel().then {
        $0.text = "새로운 상품을 등록해보세요!"
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .systemGray3
        $0.textAlignment = .center
    }
    
    let viewModel = MySellViewModel()
    let disposeBag = DisposeBag()
    var postDetailData: [PostData] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    
    // MARK: - Configurations
    private func configureHierarchy() {
        [tableView, noResultView].forEach { view.addSubview($0) }
        [noResultImageView, noResultLabel, noResultDescriptionLabel].forEach { noResultView.addSubview($0) }
        
        tableView.register(MySellTableViewCell.self, forCellReuseIdentifier: MySellTableViewCell.id)
    }
    
    private func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        noResultView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(40)
        }
        
        noResultImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }
        
        noResultLabel.snp.makeConstraints { make in
            make.top.equalTo(noResultImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        noResultDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(noResultLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "내 판매 목록"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = Constant.Color.accent
    }
    
    // MARK: - Binding
    func bind() {
        let cellLikeButtonTap = PublishSubject<String>()
        
        let input = MySellViewModel.Input(
            likeTap: cellLikeButtonTap,
            selectCell: tableView.rx.itemSelected
        )
        
        let output = viewModel.transform(input: input)
        
        output.list
            .subscribe(with: self, onNext: { owner, data in
                owner.postDetailData = data
                owner.noResultView.isHidden = !data.isEmpty
                owner.tableView.isHidden = data.isEmpty
                owner.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.list
            .bind(to: tableView.rx.items(cellIdentifier: MySellTableViewCell.id, cellType: MySellTableViewCell.self)) { [weak self] (row, element, cell) in
                guard let self = self else { return }
                
                cell.configure(with: self.postDetailData[row])
                
                cell.likeButton.rx.tap
                    .subscribe(onNext: { _ in
                        cellLikeButtonTap.onNext(self.postDetailData[row].post_id)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.selectCell
            .bind(with: self) { owner, indexPath in
                let vc = DetailViewController()
                vc.mode = .withButton
                vc.data = owner.postDetailData
                vc.row = indexPath.row
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - MySellTableViewCell
final class MySellTableViewCell: UITableViewCell {
    static let id = "MySellTableViewCell"
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowRadius = 4
    }
    
    private let productImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemGray6
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 2
    }
    
    private let locationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .systemGray
    }
    
    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Constant.Color.accent
    }
    
    let likeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "bookmark"), for: .normal)
        $0.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        $0.tintColor = Constant.Color.accent
    }
    
    private let soldOutLabel = UILabel().then {
        $0.text = "판매완료"
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .white
        $0.backgroundColor = Constant.Color.accent
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        productImageView.image = nil
        likeButton.isSelected = false
        soldOutLabel.isHidden = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        [productImageView, titleLabel, locationLabel, priceLabel, likeButton, soldOutLabel]
            .forEach { containerView.addSubview($0) }
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()//.inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }
        
        productImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView)
            make.leading.equalTo(productImageView.snp.trailing).offset(12)
            make.trailing.equalTo(likeButton.snp.leading).offset(-8)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(productImageView)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(24)
        }
        
        soldOutLabel.snp.makeConstraints { make in
            make.leading.equalTo(priceLabel.snp.trailing).offset(8)
            make.centerY.equalTo(priceLabel)
            make.width.equalTo(60)
            make.height.equalTo(22)
        }
    }
    
    // MARK: - Configuration
    func configure(with data: PostData) {
        titleLabel.text = data.title
        locationLabel.text = data.content2
        priceLabel.text = data.price.formatted() + "원"
        soldOutLabel.isHidden = data.likes2.isEmpty
        likeButton.isSelected = data.likes.contains(UserDefaultsManager.shared.user_id)
        
        if let urlString = data.files.first,
           let url = URL(string: APIKey.BaseURL + "v1/" + urlString!) {
            let modifier = AnyModifier { request in
                var request = request
                request.setValue(APIKey.SesacKey, forHTTPHeaderField: "SesacKey")
                request.setValue(UserDefaultsManager.shared.token, forHTTPHeaderField: "Authorization")
                return request
            }
            productImageView.kf.setImage(
                with: url,
                options: [.requestModifier(modifier)]
            )
        }
    }
}
