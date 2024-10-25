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
import iamport_ios
import WebKit

enum buttonMode {
    case withButton
    case withoutButton
}
class DetailViewController: UIViewController {
    var mode: buttonMode = .withoutButton
    
    lazy var wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = .white
        return view
    }()
    
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
        $0.pageIndicatorTintColor = .grey
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
        $0.setImage(UIImage(named: "book_mark"), for: .normal)
        $0.setImage(UIImage(named: "book_mark.fill"), for: .selected)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Constant.Color.accent
        $0.transform = CGAffineTransform(scaleX: 1.5, y: 2) // 이미지를 2배로 확대
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
        $0.textColor = .grey
    }
    let soldoutLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .grey
        $0.textAlignment = .center
    }
    let uiView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.backgroundColor = .oasis
    }
    let newOrusedLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = Constant.Color.accent
        $0.textAlignment = .center
    }
    let vSeparator = UIView().then {
        $0.backgroundColor = .grey
    }
    let separator = UIView().then {
        $0.backgroundColor = .grey
    }
    let brandLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
    }
    let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
    }
    let categoryLabel = UILabel().then {
        $0.textColor = .grey
        $0.font = .systemFont(ofSize: 15)
    }
    let createdLabel = UILabel().then {
        $0.textColor = .grey
        $0.font = .systemFont(ofSize: 15)
    }
    let priceLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 17)
    }
    let buyButton = PointButton(title: "구매하기").then {
        $0.addTarget(self, action: #selector(buyButtonClicked), for: .touchUpInside)
        $0.backgroundColor = Constant.Color.accent
        $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
    }
    let contentLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingTail // 잘린 부분을 "..."으로 표시
    }
    let separator2 = UIView().then {
        $0.backgroundColor = .grey
    }
    let commentLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 15)
    }
    let tableView = UITableView().then { _ in
    }
    @objc func buyButtonClicked() {
        let payment = IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(Header.sesacKey)_\(Int(Date().timeIntervalSince1970))",
            amount: "1").then {//"\(data![row].price)").then {
                $0.pay_method = PayMethod.card.rawValue
                $0.name = data![row].title
                $0.buyer_name = UserDefaultsManager.shared.nick
                $0.app_scheme = "sesac"
            }
        
        wkWebView.isHidden = false

        Iamport.shared.paymentWebView(
            webViewMode: wkWebView,
            userCode: "imp57573124",
            payment: payment) { [weak self] iamportResponse in
                print(String(describing: iamportResponse))
                if ((iamportResponse?.success) != nil) {
                    self!.showAlert(title: "결제 성공", message: "상품 구매가 완료되었습니다.")
                } else {
                    self!.showAlert(title: "결제 실패", message: "결제 중 오류가 발생했습니다. 다시 시도해주세요.")
                }
            }
    }
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        setupNavigationBar()
    }
    func configureHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(wkWebView)
        scrollView.addSubview(contentView)
        //view.addSubview(collectionView)
        //view.addSubview(pageControl) // UIPageControl 추가
        collectionView.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: DetailCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        [collectionView, pageControl, likeFuncButton, nickLabel, locationLabel, soldoutLabel, uiView, newOrusedLabel, vSeparator, separator, brandLabel, titleLabel, categoryLabel, createdLabel, priceLabel, buyButton, contentLabel, separator2, commentLabel, tableView].forEach { contentView.addSubview($0) }
        
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    func configureLayout() {
        wkWebView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
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
            make.width.equalTo(20)
            make.height.equalTo(20)
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
        buyButton.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(contentView).inset(20)
            make.height.equalTo(44)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(buyButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(contentView).inset(20)
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
        wkWebView.isHidden = true
        navigationController?.navigationBar.tintColor = Constant.Color.accent
        scrollView.contentInsetAdjustmentBehavior = .never// 스크롤 뷰 자동 조정 방지
        
        //메인에서는 수정,삭제 안되고 마이-나의판매내역-셀클릭해서만 보이도록!
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(barButtonCliecked))
        navigationItem.rightBarButtonItem = rightBarButton
        
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
        
        var text = ""
        switch data![row].product_id {
        case "dbokeyt_made":
            text = "기성품 키보드"
        case "dbokey_custom":
            text = "커스텀 키보드"
        case "dbokey_keycap":
            text = "키캡"
        case "dbokey_switch":
            text = "스위치"
        case "dbokey_artisan":
            text = "아티산"
        case "dbokey_etc":
            text = "기타"
        default:
            text = ""
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.grey]
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
    private func setupNavigationBar() {
        switch mode {
        case .withButton:
            let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(barButtonCliecked))
            navigationController?.navigationItem.rightBarButtonItem = rightBarButton
            rightBarButton.tintColor = Constant.Color.accent
            buyButton.isEnabled = false
        case .withoutButton:
            //navigationItem.rightBarButtonItem?.isHidden = true 아래랑 같은 기능
            navigationItem.rightBarButtonItem = nil
            buyButton.isEnabled = true
        }
    }
    @objc func barButtonCliecked() {
        let alertSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      
        let editAction = UIAlertAction(title: "게시글 수정", style: .default) { _ in
            let vc = WriteViewController()
            vc.mode = .editMode
            vc.postID = self.data![self.row].post_id
            // 이미지 데이터 전달
            for i in 0..<self.data![self.row].files.count {
                if let firstImageURLString = self.data![self.row].files[i],
                   let url = URL(string: APIKey.BaseURL + "v1/" + firstImageURLString) {
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        switch result {
                        case .success(let imageResult):
                            vc.imageViews[i].image = imageResult.image
                            vc.removeButtons[i].isHidden = false
                        case .failure(let error):
                            print("이미지 로드 실패: \(error)")
                        }
                    }
                }
            }
            
            // 텍스트 데이터 전달
            vc.brandTextField.text = self.data![self.row].content1
            vc.titleTextField.text = self.data![self.row].title
            vc.locationTextField.text = self.data![self.row].content2
            vc.priceTextField.text = String(self.data![self.row].price)
            
            // contentTextView 설정
            if !self.data![self.row].content.isEmpty {
                vc.contentTextView.text = self.data![self.row].content
                vc.contentTextView.textColor = .black
            } else {
                vc.contentTextView.text = "게시글 내용을 작성해주세요\n- 구매시기\n- 자세한 설명"
                vc.contentTextView.textColor = .grey
            }
            
            // 카테고리 설정
            vc.selectedCategory = self.data![self.row].product_id
            // 카테고리 버튼 텍스트 설정
            switch self.data![self.row].product_id {
            case "dbokeyt_made":
                vc.categoryButton.setTitle("기성품 키보드", for: .normal)
            case "dbokey_custom":
                vc.categoryButton.setTitle("커스텀 키보드", for: .normal)
            case "dbokey_keycap":
                vc.categoryButton.setTitle("키캡", for: .normal)
            case "dbokey_switch":
                vc.categoryButton.setTitle("스위치", for: .normal)
            case "dbokey_artisan":
                vc.categoryButton.setTitle("아티산", for: .normal)
            case "dbokey_etc":
                vc.categoryButton.setTitle("기타", for: .normal)
            default:
                vc.categoryButton.setTitle("", for: .normal)
            }
            // 상태(중고/새상품) 설정
            if self.data![self.row].content3 == "중고용품" {
                vc.segmentedControl.selectedSegmentIndex = 0
            } else {
                vc.segmentedControl.selectedSegmentIndex = 1
            }
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            var categoryValue = ""
            switch self.categoryLabel.text {
            case "기성품 키보드":
                categoryValue = "dbokeyt_made"
            case "커스텀 키보드":
                categoryValue = "dbokey_custom"
            case "키캡":
                categoryValue = "dbokey_keycap"
            case "스위치":
                categoryValue = "dbokey_switch"
            case "아티산":
                categoryValue = "dbokey_artisan"
            case "기타":
                categoryValue  = "dbokey_etc"
            default:
                categoryValue  = ""
            }
        }
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            let alertController = UIAlertController(title: nil, message: "게시글을 삭제하시겠어요?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                //TODO: 삭제 API
                NetworkManager.deletePost(post_id: self.data![self.row].post_id) { success in
                    if success {
                        let alertConfirmController = UIAlertController(title: nil, message: "게시글이 삭제되었습니다.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                        alertConfirmController.addAction(okAction)
                        self.present(alertConfirmController, animated: true)
                    } else {
                        let alertConfirmController = UIAlertController(title: "삭제 실패", message: "다시 시도해주세요.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "확인", style: .default)
                        alertConfirmController.addAction(okAction)
                        self.present(alertConfirmController, animated: true, completion: nil)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            self.present(alertController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
        
        alertSheetController.addAction(editAction)
        alertSheetController.addAction(deleteAction)
        alertSheetController.addAction(cancelAction)

        present(alertSheetController, animated: true, completion: nil)
        }
    }

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data![row].comments.count
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
