//
//  MyViewController.swift
//  Dbokey
//
//  Created by 소정섭 on 8/25/24.
//

import UIKit
import SnapKit

class MyViewController: UIViewController {
    
    let tableView = UITableView()
    let titles = ["나의 관심 목록","나의 판매내역","내 게시글", "로그아웃","탈퇴하기"]
    static var cartList:[String] = []
    static var getKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "\(UserDefaultsManager.shared.nick)"
        navigationItem.backButtonTitle = ""

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.identifier)
        tableView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        tableView.separatorColor = .black
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData() // TODO: EDIT PROFILE갔다가 뒤로 오면 userDefaults가 저장되는데 이미지는 안바뀌어서 바뀌도록
    }
}
extension UIViewController {
    func showAlert(title: String, message: String, ok:String, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let delete = UIAlertAction(title: ok, style: .destructive) { _ in
            completionHandler()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true)
    }
}
extension MyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("아무것도")
        case 1:
            print("나의 관심 목록 vc예정")
        case 2:
            let vc = MySellViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            print("내 커뮤니티클 vc예정")
        case 4:
            showAlert(title: "로그아웃", message: "로그아웃 하시겠습니까?", ok: "확인") {
                if let appDomain = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: appDomain)
                }
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let SceneDelegate = windowScene?.delegate as? SceneDelegate
                
                let navigationController = LoginViewController()
                
                SceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: navigationController)
                SceneDelegate?.window?.makeKeyAndVisible()
            }
        case 5:
            showAlert(title: "탈퇴하기", message: "정말 탈퇴 하시겠습니까?", ok: "확인") {
                NetworkManager.withdraw()
                if let appDomain = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: appDomain)
                }
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let SceneDelegate = windowScene?.delegate as? SceneDelegate
                
                let navigationController = LoginViewController()
                
                SceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: navigationController)
                SceneDelegate?.window?.makeKeyAndVisible()
            }
        default:
            print("아무것도")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150
        }
        else {
            return 40
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
        if indexPath.row == 0 {
            //프로필이 필요할까?
            cell.profileImage.layer.borderColor = UIColor(red: 239/255, green: 137/255, blue: 71/255, alpha: 1.0).cgColor
            cell.profileImage.layer.borderWidth = 3
            cell.profileImage.image = UIImage(named: "person")
            cell.profileLabel.text = "profileLabel"//
            cell.profileDateLabel.text = "profileDateLabel"
            //
            cell.nextImage.image = UIImage(systemName: "chevron.right")
        }
        else if indexPath.row == 1 {
            cell.textLabel!.text = titles[indexPath.row-1]
            cell.textLabel!.font = .systemFont(ofSize: 14)
            
            cell.bagListLabel2.text = "의 상품"

            cell.bagListLabel.text = "bagListLabel개"//좋아요 api 작성 여기에
                
            cell.bagImage.image = UIImage(systemName: "heart.fill")
        }
        else {
            cell.textLabel!.text = titles[indexPath.row-1]
            cell.textLabel!.font = .systemFont(ofSize: 14)
        }
        if indexPath.row == 0 {
            cell.selectionStyle = .none
        }
        return cell
    }
    
}
