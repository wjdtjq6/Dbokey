//
//  Tabbar.swift
//  Dbokey
//
//  Created by 소정섭 on 8/25/24.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = Constant.Color.accent
        tabBar.unselectedItemTintColor = .grey

        let main = MainViewController()
        let nav1 = UINavigationController(rootViewController: main)
        nav1.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
       
        let community = CommunityViewController()
        let nav2 = UINavigationController(rootViewController: community)
        nav2.tabBarItem = UITabBarItem(title: "커뮤니티", image: UIImage(systemName: "person.2"), selectedImage: UIImage(systemName: "person.2.fill"))
        
        let my = MyViewController()
        let nav3 = UINavigationController(rootViewController: my)
        nav3.tabBarItem = UITabBarItem(title: "마이", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        setViewControllers([nav1,nav2,nav3], animated: true)
    }
}
