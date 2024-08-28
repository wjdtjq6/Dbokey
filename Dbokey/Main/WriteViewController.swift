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

final class WriteViewController: UIViewController {
    private let imageButton = UIButton().then {
        $0.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 1
        $0.tintColor = .black
        $0.addTarget(self, action: #selector(imageButtonClicked), for: .touchUpInside)
    }
    private let imageContainerViews: [UIView] = (0..<5).map { _ in
       UIView().then {
           $0.layer.cornerRadius = 5
       }
   }
   private let imageViews: [UIImageView] = (0..<5).map { _ in
       UIImageView().then {
           $0.contentMode = .scaleToFill
           $0.layer.masksToBounds = true
           $0.layer.cornerRadius = 5
       }
   }
   private let removeButtons: [UIButton] = (0..<5).map { _ in
       UIButton().then {
           $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
           $0.tintColor = .white
           $0.layer.cornerRadius = 10
           $0.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.7)
           $0.isHidden = true
           $0.isUserInteractionEnabled = true
       }
   }
    
    private let brandTextField = UITextField().then {
        $0.placeholder = "브랜드명"
        $0.borderStyle = .roundedRect
    }
    private let categoryButton = UIButton().then {
            $0.setTitle("카테고리 선택", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 5
            $0.contentHorizontalAlignment = .left
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            $0.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        }
    private let categories = [
        ("기성품 키보드", "dbokey_market_made"),
        ("커스텀 키보드", "dbokey_market_custom"),
        ("키캡", "dbokey_market_keycap"),
        ("아티산", "dbokey_market_artisan"),
        ("스위치", "dbokey_market_switch"),
        ("기타", "dbokey_market_etc")
    ]
    private var selectedCategory: String = ""
    
    private let titleTextField = UITextField().then {
        $0.placeholder = "용품명"
        $0.borderStyle = .roundedRect
    }
    private let priceTextField = UITextField().then {
        $0.placeholder = "판매가격"
        $0.borderStyle = .roundedRect
        $0.keyboardType = .numberPad
    }
    private let segmentedControl = UISegmentedControl(items: ["중고용품", "새상품"]).then {
        $0.selectedSegmentIndex = 0  // 기본값으로 첫 번째 항목 선택
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    private let stateLabel = UILabel().then {
        $0.text = "물품상태"
    }
    private let locationTextField = UITextField().then {
        $0.placeholder = "판매 지역(ex. 서울시 구로동)"
        $0.borderStyle = .roundedRect
    }
    private let contentTextView = UITextView().then {
        $0.text = "게시글 내용을 작성해주세요\n- 구매시기\n- 자세한 설명"
        $0.textColor = .lightGray
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
        
//        // iPad에서 사용할 때 필요한 설정
//        if let popoverController = alertController.popoverPresentationController {
//            popoverController.sourceView = categoryButton
//            popoverController.sourceRect = categoryButton.bounds
//        }
        
        present(alertController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLauyout()
        configureUI()
        setupRemoveButtons()
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
        leftBarButton.tintColor = .black
        let rightBarButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(rightBarButtonCliecked))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.tintColor = .black
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
        
//        let allConditionsMet = !images.isEmpty &&
//                                   !brandTextField.text!.isEmpty &&
//                                   !titleTextField.text!.isEmpty &&
//                                   contentTextView.textColor != UIColor.lightGray &&
//                                   !locationTextField.text!.isEmpty
        
        NetworkManager.uploadFiles(images: images) { result in
            switch result {
            case .success(let success):
                dump(success.files)
                if self.imageViews.isEmpty {
                    //DispatchQueue.main.async {
                        self.showAlert(title: "업로드 실패", message: "이미지를 추가해주세요.")
                    //}
                }
                else if self.brandTextField.text!.isEmpty {
                    self.showAlert(title: "업로드 실패", message: "브랜드명을 작성해주세요.")
                }
                else if self.selectedCategory == "" {
                    self.showAlert(title: "업로드 실패", message: "카테고리를 선택해주세요.")
                }
                else if self.titleTextField.text!.isEmpty {
                    self.showAlert(title: "업로드 실패", message: "용품명을 작성해주세요.")
                }
                else if (self.contentTextView.textColor == UIColor.lightGray) &&  self.contentTextView.text.isEmpty {
                    self.showAlert(title: "업로드 실패", message: "내용을 작성해주세요.")
                }
                else if self.locationTextField.text!.isEmpty {
                    self.showAlert(title: "업로드 실패", message: "판매 지역을 작성해주세요.")
                }
                else {
                    NetworkManager.uploadPostContents(title: self.titleTextField.text!, content: self.contentTextView.text!, content1: self.brandTextField.text!, content2: self.locationTextField.text!, content3: self.content3, price: Int(self.priceTextField.text!) ?? 0, product_id: self.selectedCategory, files: success.files) { result in
                            switch result {
                                case .success(let success):
                                    dump(success.files)
                                    self.navigationController?.dismiss(animated: true)
                                case .failure(let error):
                                    dump(error)
                                    self.showAlert(title: "업로드 실패", message: "네트워크 연결을 확인해주세요")
                            }
                        }
                }
                

            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.showAlert(title: "업로드 실패", message: "이미지를 추가해주세요.")//400:현제, 419:다시 로그인 해주세요?
                }
            }
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
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "게시글 내용을 작성해주세요\n- 구매시기\n- 자세한 설명"
            textView.textColor = .lightGray
        }
    }
}
