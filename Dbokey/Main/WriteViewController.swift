//
//  WriteViewContorller.swift
//  Dbokey
//
//  Created by 소정섭 on 8/26/24.
//

import UIKit
import Then
import SnapKit
import PhotosUI
import RxSwift

enum uploadMode {
    case writeMode
    case editMode
}
class WriteViewController: UIViewController {
    var mode: uploadMode = .writeMode
    var postID = ""
    private let disposeBag = DisposeBag()
    private let imageButton = UIButton().then {
        $0.backgroundColor = .systemGray6
        $0.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray4.cgColor
        $0.tintColor = Constant.Color.accent
        
        // 그림자 효과
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowRadius = 1
        
        // 카메라 아이콘 크기 조정
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
        
        $0.addTarget(self, action: #selector(imageButtonClicked), for: .touchUpInside)
    }
    private let imageContainerViews: [UIView] = (0..<5).map { _ in
       UIView().then {
           $0.layer.cornerRadius = 5
       }
   }
   var imageViews: [UIImageView] = (0..<5).map { _ in
       UIImageView().then {
           $0.contentMode = .scaleToFill
           $0.layer.masksToBounds = true
           $0.layer.cornerRadius = 5
       }
   }
   let removeButtons: [UIButton] = (0..<5).map { _ in
       UIButton().then {
           $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
           $0.tintColor = .white
           $0.layer.cornerRadius = 10
           $0.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.7)
           $0.isHidden = true
           $0.isUserInteractionEnabled = true
       }
   }
    var brandTextField = UITextField().then {
        $0.placeholder = "브랜드명"
        $0.borderStyle = .roundedRect
    }
    var categoryButton = UIButton().then {
        $0.setTitle("카테고리 선택", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16)
        $0.setTitleColor(.black, for: .normal)
        
        // 배경색과 테두리 설정
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray4.cgColor
        
        // 내부 여백과 그림자 설정
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowRadius = 1
        
        // 오른쪽 화살표 아이콘 추가
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let arrowImage = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        $0.setImage(arrowImage, for: .normal)
        $0.tintColor = .black
        $0.semanticContentAttribute = .forceRightToLeft
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        // 터치 효과 설정
        $0.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
    }
    private let categories = [
        ("기성품 키보드", "dbokeyt_made"),
        ("커스텀 키보드", "dbokey_custom"),
        ("키캡", "dbokey_keycap"),
        ("아티산", "dbokey_artisan"),
        ("스위치", "dbokey_switch"),
        ("기타", "dbokey_etc")
    ]
    var selectedCategory: String = ""
    
    var titleTextField = UITextField().then {
        $0.placeholder = "용품명"
        $0.borderStyle = .roundedRect
    }
    var priceTextField = UITextField().then {
        $0.placeholder = "판매가격"
        $0.borderStyle = .roundedRect
        $0.keyboardType = .numberPad
    }
    var segmentedControl = UISegmentedControl(items: ["중고용품", "새상품"]).then {
        $0.selectedSegmentIndex = 0  // 기본값으로 첫 번째 항목 선택
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
       // $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        //$0.backgroundColor = Constant.Color.accent
        //$0.selectedSegmentTintColor = Constant.Color.chardonnay
    }
    private let stateLabel = UILabel().then {
        $0.text = "물품상태"
    }
    var locationTextField = UITextField().then {
        $0.placeholder = "판매 지역(ex. 서울시 구로동)"
        $0.borderStyle = .roundedRect
    }
    var contentTextView = UITextView().then {
        $0.text = "게시글 내용을 작성해주세요\n- 구매시기\n- 자세한 설명"
        $0.textColor = .grey
        $0.textAlignment = .left  // 텍스트 정렬 (상단에 자동 정렬됨)
        //$0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray6.cgColor
        $0.layer.cornerRadius = 15
    }
    private var selectedImageViews: [UIImageView] = []
    
    private var content3 = "중고용품"
    
    @objc private func categoryButtonTapped() {
        let alertController = UIAlertController(title: "카테고리 선택", message: nil, preferredStyle: .actionSheet)
        
        for (categoryName, categoryId) in categories {
            let action = UIAlertAction(title: categoryName, style: .default) { [weak self] _ in
                self?.selectedCategory = categoryId
                self?.categoryButton.setTitle(categoryName, for: .normal)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLauyout()
        configureUI()
        setupRemoveButtons()
        setupTextView()
    }
    private func setupTextView() {
        contentTextView.delegate = self
        if contentTextView.text == "게시글 내용을 작성해주세요\n- 구매시기\n- 자세한 설명" {
            contentTextView.textColor = .grey
        } else {
            contentTextView.textColor = .black
        }
    }
    @objc private func imageButtonClicked() {
        for i in 0..<5 {
            imageViews[i].image = nil
            removeButtons[i].isHidden = true
        }
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            content3 = "중고용품"
        case 1:
            content3 = "새상품"
        default:
            content3 = "중고용품"
        }
    }
    func configureHierarchy() {
        [imageButton, brandTextField,categoryButton, titleTextField, priceTextField, stateLabel, segmentedControl, contentTextView, locationTextField].forEach { view.addSubview($0) }
        contentTextView.delegate = self
        for i in 0..<5 {
            view.addSubview(imageContainerViews[i])
            imageContainerViews[i].addSubview(imageViews[i])
            imageContainerViews[i].addSubview(removeButtons[i])
        }
    }
    func configureLauyout() {
        imageButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.equalTo((view.bounds.width - 90) / 6)
            make.height.equalTo((view.bounds.width - 90) / 6)
        }
        for (index, containerView) in imageContainerViews.enumerated() {
            containerView.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
                if index == 0 {
                    make.leading.equalTo(imageButton.snp.trailing).offset(10)
                } else {
                    make.leading.equalTo(imageContainerViews[index-1].snp.trailing).offset(10)
                }
                make.width.equalTo((view.bounds.width - 90) / 6)
                make.height.equalTo((view.bounds.width - 90) / 6)
            }

            imageViews[index].snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            removeButtons[index].snp.makeConstraints { make in
                make.top.trailing.equalToSuperview().inset(1)
                make.width.height.equalTo(20)
            }
                }
        brandTextField.snp.makeConstraints { make in
            make.top.equalTo(imageButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo((view.bounds.width - 50) / 2)
            make.height.equalTo(40)
        }
        categoryButton.snp.makeConstraints { make in
            make.top.equalTo(brandTextField)
            make.leading.equalTo(brandTextField.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(brandTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        priceTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        stateLabel.snp.makeConstraints { make in
            make.top.equalTo(priceTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(25)
        }
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(150)
        }
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        locationTextField.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(leftBarButtonClicked))
        navigationItem.leftBarButtonItem = leftBarButton
        leftBarButton.tintColor = Constant.Color.accent
        let rightBarButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(rightBarButtonCliecked))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.tintColor = Constant.Color.accent
    }
    @objc private func leftBarButtonClicked() {
        navigationController?.dismiss(animated: true)
    }
    @objc private func rightBarButtonCliecked() {
        uploadPostFiles()
    }
    private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    private func uploadPostFiles() {
        let images = imageViews.compactMap { $0.image?.jpegData(compressionQuality: 0.5) }
        
        // 입력 검증
        guard !images.isEmpty else {
            showAlert(title: "업로드 실패", message: "이미지를 추가해주세요.")
            return
        }
        guard !brandTextField.text!.isEmpty else {
            showAlert(title: "업로드 실패", message: "브랜드명을 작성해주세요.")
            return
        }
        guard !selectedCategory.isEmpty else {
            showAlert(title: "업로드 실패", message: "카테고리를 선택해주세요.")
            return
        }
        guard !titleTextField.text!.isEmpty else {
            showAlert(title: "업로드 실패", message: "용품명을 작성해주세요.")
            return
        }
        guard !(contentTextView.textColor == UIColor.grey && contentTextView.text.isEmpty) else {
            showAlert(title: "업로드 실패", message: "내용을 작성해주세요.")
            return
        }
        guard !locationTextField.text!.isEmpty else {
            showAlert(title: "업로드 실패", message: "판매 지역을 작성해주세요.")
            return
        }

        NetworkManager.uploadFiles(images: images)
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] uploadResult -> Single<PostData> in
                guard let self = self else { return .error(NetworkError.unknown) }
                
                if self.mode == .writeMode {
                    return NetworkManager.uploadPostContents(
                        title: self.titleTextField.text!,
                        content: self.contentTextView.text!,
                        content1: self.brandTextField.text!,
                        content2: self.locationTextField.text!,
                        content3: self.content3,
                        price: Int(self.priceTextField.text!) ?? 0,
                        product_id: self.selectedCategory,
                        files: uploadResult.files
                    )
                } else {
                    let categoryValue = self.getCategoryValue()
                    let selected = self.segmentedControl.selectedSegmentIndex == 0 ? "중고용품" : "새상품"
                    
                    return NetworkManager.editPost(
                        post_id: self.postID,
                        title: self.titleTextField.text!,
                        content: self.contentTextView.text,
                        content1: self.brandTextField.text!,
                        content2: self.locationTextField.text!,
                        content3: selected,
                        price: Int(self.priceTextField.text!)!,
                        product_id: categoryValue,
                        files: uploadResult.files
                    )
                }
            }
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.dismiss(animated: true)
                let title = self.mode == .writeMode ? "업로드 성공" : "게시글 수정 성공"
                let message = self.mode == .writeMode ? "게시글 업로드가 완료되었습니다." : "게시글 수정이 완료되었습니다."
                self.showAlert(title: title, message: message)
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                print("Error:", error)
                let title = self.mode == .writeMode ? "업로드 실패" : "게시글 수정 실패"
                self.showAlert(title: title, message: "네트워크 연결을 확인해주세요")
            })
            .disposed(by: disposeBag)
    }

    // 카테고리 값을 얻는 헬퍼 메서드
    private func getCategoryValue() -> String {
        switch categoryButton.titleLabel?.text {
        case "기성품 키보드": return "dbokeyt_made"
        case "커스텀 키보드": return "dbokey_custom"
        case "키캡": return "dbokey_keycap"
        case "스위치": return "dbokey_switch"
        case "아티산": return "dbokey_artisan"
        case "기타": return "dbokey_etc"
        default: return ""
        }
    }    
    private func setupRemoveButtons() {
        for (index, button) in removeButtons.enumerated() {
            button.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
        }
    }
    @objc private func removeButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        imageViews[index].image = nil
        removeButtons[index].isHidden = true
        print("이미지 \(index + 1) 삭제됨")
    }
}
extension WriteViewController: UITextViewDelegate, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for (index, result) in results.enumerated() {
            guard index < 5 else { break }
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.imageViews[index].image = image
                        self.removeButtons[index].isHidden = false
                    }
                }
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .grey {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "게시글 내용을 작성해주세요\n- 구매시기\n- 자세한 설명"
            textView.textColor = .grey
        }
    }
}
