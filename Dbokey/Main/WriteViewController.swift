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

class WriteViewController: UIViewController {
    private let imageButton = UIButton().then {
        $0.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 5
        $0.tintColor = .lightGray
        $0.addTarget(self, action: #selector(imageButtonClicked), for: .touchUpInside)
    }
    private let imageView1 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 5
    }
    private let imageView2 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 5
    }
    private let imageView3 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 5
    }
    private let imageView4 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 5
    }
    private let imageView5 = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 5
    }
    private let brandTextField = UITextField().then {
        $0.placeholder = "브랜드명"
        $0.borderStyle = .roundedRect
    }
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
    //TODO: 브랜드명 + DetailViewController에도 추가 제목앞에 [콕스]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLauyout()
        configureUI()
    }
    @objc private func imageButtonClicked() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("중고용품")
        case 1:
            print("새상품")
        default:
            print("중고용품")
        }
    }
    func configureHierarchy() {
        [imageButton, imageView1, imageView2, imageView3, imageView4, imageView5, brandTextField, titleTextField, priceTextField, stateLabel, segmentedControl, contentTextView, locationTextField].forEach { view.addSubview($0) }
        contentTextView.delegate = self
    }
    func configureLauyout() {
        imageButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.equalTo((view.bounds.width - 90) / 6)
            make.height.equalTo((view.bounds.width - 90) / 6)
        }
        imageView1.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(imageButton.snp.trailing).offset(10)
            make.width.equalTo((view.bounds.width - 90) / 6)
            make.height.equalTo((view.bounds.width - 90) / 6)
        }
        imageView2.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(imageView1.snp.trailing).offset(10)
            make.width.equalTo((view.bounds.width - 90) / 6)
            make.height.equalTo((view.bounds.width - 90) / 6)
        }
        imageView3.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(imageView2.snp.trailing).offset(10)
            make.width.equalTo((view.bounds.width - 90) / 6)
            make.height.equalTo((view.bounds.width - 90) / 6)
        }
        imageView4.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(imageView3.snp.trailing).offset(10)
            make.width.equalTo((view.bounds.width - 90) / 6)
            make.height.equalTo((view.bounds.width - 90) / 6)
        }
        imageView5.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(imageView4.snp.trailing).offset(10)
            make.width.equalTo((view.bounds.width - 90) / 6)
            make.height.equalTo((view.bounds.width - 90) / 6)
        }
        brandTextField.snp.makeConstraints { make in
            make.top.equalTo(imageButton.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
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
    @objc func leftBarButtonClicked() {
        navigationController?.dismiss(animated: true)
    }
    @objc func rightBarButtonCliecked() {
        print(#function)
        uploadPostFiles()
    }
    func uploadPostFiles() {
        
    }
}
extension WriteViewController: UITextViewDelegate, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        selectedImageViews = [imageView1,imageView2, imageView3, imageView4, imageView5]
        for (index, result) in results.enumerated() {
            guard index < 5 else { break }
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.selectedImageViews[index].image = image
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
