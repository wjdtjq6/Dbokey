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
    var data: [PostData]?
    var row = 0
    var category = ""
    let scrollView = UIScrollView()
    let contentView = UIView()
    let collectionView: UICollectionView = {
           let layout = DetailViewController.layout()
           let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
           collectionView.decelerationRate = .fast // 스크롤 감속 속도를 빠르게 설정
           collectionView.isPagingEnabled = true//bottom에 paging
           return collectionView
       }()
    let pageControl = UIPageControl().then {
        $0.pageIndicatorTintColor = .lightGray
        $0.currentPageIndicatorTintColor = .white
    }
    static func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: width, height: 400)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }
    let likeFuncButton = UIButton().then {
        $0.setImage(UIImage(systemName: "bookmark"), for: .normal)
        $0.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        $0.tintColor = .white
        $0.transform = CGAffineTransform(scaleX: 2, y: 1.5) // 이미지를 2배로 확대
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addTarget(self, action: #selector(likeFuncButtonClicked), for: .touchUpInside)
    }
    @objc func likeFuncButtonClicked() {
        if likeFuncButton.isSelected {
            NetworkManager.likePost(postID: data![row].post_id, like_status: false) { result in
                switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.likeFuncButton.isSelected.toggle()
                        }
                    case .failure(let error):
                        print("Error updating like status: \(error)")
                    }
            }
        }
        else {
            NetworkManager.likePost(postID: data![row].post_id, like_status: true) { result in
                switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.likeFuncButton.isSelected.toggle()
                        }
                    case .failure(let error):
                        print("Error updating like status: \(error)")
                    }
            }
        }
    }
    let nickLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
    }
    var locationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 11)
        $0.textColor = .gray
    }
    let soldoutLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    let uiView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray6
    }
    let newOrusedLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    let vSeparator = UIView().then {
        $0.backgroundColor = .gray
    }
    let separator = UIView().then {
        $0.backgroundColor = .gray
    }
    let brandLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
    }
    let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
    }
    let categoryLabel = UILabel().then {
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 15)
    }
    let createdLabel = UILabel().then {
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 15)
    }
    let priceLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
    }
    let contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingTail // 잘린 부분을 "..."으로 표시
    }
    let separator2 = UIView().then {
        $0.backgroundColor = .gray
    }
    let commentLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 15)
    }
    let tableView = UITableView().then { _ in
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        //view.addSubview(collectionView)
        //view.addSubview(pageControl) // UIPageControl 추가
        collectionView.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: DetailCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        //view.addSubview(likeFuncButton)
//        view.addSubview(nickLabel)
        //view.addSubview(locationLabel)
        //view.addSubview(soldoutLabel)
        //view.addSubview(uiView)
        //view.addSubview(newOrusedLabel)
        //view.addSubview(vSeparator)
        //view.addSubview(separator)
        
        //view.addSubview(brandLabel)
        //view.addSubview(titleLabel)
        //view.addSubview(categoryLabel)
        //view.addSubview(createdLabel)
        //view.addSubview(priceLabel)
        //view.addSubview(contentLabel)
        
        //view.addSubview(separator2)
        //view.addSubview(commentLabel)
        //view.addSubview(tableView)
        
        [collectionView, pageControl, likeFuncButton, nickLabel, locationLabel, soldoutLabel, uiView, newOrusedLabel, vSeparator, separator, brandLabel, titleLabel, categoryLabel, createdLabel, priceLabel, contentLabel, separator2, commentLabel, tableView].forEach { contentView.addSubview($0) }
        
        
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide) // Scroll 방향을 수직으로 설정
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.horizontalEdges.equalTo(contentView)
            make.height.equalTo(300)
        }
        pageControl.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(collectionView.snp.bottom)
        }
        likeFuncButton.snp.makeConstraints { make in
            make.bottom.equalTo(collectionView.snp.bottom).inset(20)
            make.trailing.equalTo(contentView).inset(20)
        }
        nickLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
        }
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(nickLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView).offset(20)
        }
        soldoutLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.trailing.equalTo(contentView).inset(110)
            make.bottom.equalTo(locationLabel.snp.bottom)
            make.width.equalTo(80)
        }
        uiView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.trailing.equalTo(contentView).inset(20)
            make.bottom.equalTo(locationLabel.snp.bottom)
            make.width.equalTo(80)
        }
        newOrusedLabel.snp.makeConstraints { make in
            make.edges.equalTo(uiView)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.width.equalTo(UIScreen.main.bounds.width/2-20)
            make.height.equalTo(1)
        }
        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(20)
            make.leading.equalTo(brandLabel.snp.trailing)
        }
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView).offset(20)
        }
        createdLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(categoryLabel.snp.trailing).offset(5)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.trailing.equalTo(contentView).inset(20)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(createdLabel.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).inset(20)
        }
        separator2.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(1)
        }
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(separator2.snp.bottom).offset(10)
            make.leading.equalTo(contentView).offset(20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.bottom.equalTo(contentView) // 마지막으로 bottom 설정
            make.height.equalTo(150)//(tableView.contentSize.height) // contentSize를 사용하여 동적 높이 설정
        }
    }

    func configureUI() {
        view.backgroundColor = .white
        
        pageControl.numberOfPages = data?[row].files.count ?? 0
        pageControl.currentPage = 0

        likeFuncButton.isSelected =  data![row].likes.contains(UserDefaultsManager.shared.user_id)
        
        nickLabel.text =  data![row].creator.nick
        locationLabel.text =  data![row].content2//content3이었음
        if  data![row].likes2.isEmpty {
            soldoutLabel.text = ""
        } else {
            soldoutLabel.text = "거래완료"
        }
        newOrusedLabel.text =  data![row].content3//conten4였음
        
        brandLabel.text = "["+( data![row].content1)+"] "
        titleLabel.text =  data![row].title
        let text = category
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.darkGray]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        categoryLabel.attributedText = attributedString
        let dateString =  data![row].createdAt
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // 옵션 설정
        guard let date = dateFormatter.date(from: dateString) else {
            print("날짜 문자열 변환 실패")
            fatalError("날짜 문자열 변환 실패")
        }
        let currenDate = Date()
        let timeInterval = currenDate.timeIntervalSince(date)
        let hours = timeInterval / 3600
        let hoursAgo = Int(hours)
        createdLabel.text = hoursAgo >= 24 ? "• \(hoursAgo/24)일 전" : "• \(hoursAgo%24)시간 전"
        priceLabel.text = data![row].price.formatted() + "원"//(Int(( data![row].price))?.formatted())! + "원"//.content2였음
        contentLabel.text =  data![row].content
        commentLabel.text = "댓글\( data![row].comments.count)"
        tableView.rowHeight = 30
    }
}
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ( data![row].comments.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
        if  data![row].comments[indexPath.row]?.creator.nick ==  data![row].creator.nick {
            cell.nickLabel.text = "작성자 " + ( data![row].comments[indexPath.row]?.creator.nick)! + ": "
        } else {
            cell.nickLabel.text = ( data![row].comments[indexPath.row]?.creator.nick)! + ": "
        }
        cell.commentLabel.text =  data![row].comments[indexPath.row]?.content
        return cell
    }
    
    
}
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data![row].files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.identifier, for: indexPath) as! DetailCollectionViewCell
        cell.backgroundColor = UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)

        if let urlString =  data![row].files[indexPath.item], let url = URL(string: APIKey.BaseURL+"v1/" + urlString) {
            let modifier = AnyModifier { request in
                var request = request
                request.setValue(APIKey.SesacKey, forHTTPHeaderField: "SesacKey")
                request.setValue(UserDefaultsManager.shared.token, forHTTPHeaderField: "Authorization")
                return request
            }
            cell.imageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
        }
        return cell
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex*cellWidthIncludingSpacing, y: 0)
        targetContentOffset.pointee = offset
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.size.width
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)
        pageControl.currentPage = currentPage
    }
}
