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
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .lightGray

        let main = MainViewController()
       //let nav1 = UINavigationController(rootViewController: main)
        main.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
       
        let community = CommunityViewController()
        //let nav2 = UINavigationController(rootViewController: community)
        community.tabBarItem = UITabBarItem(title: "커뮤니티", image: UIImage(systemName: "person.2"), selectedImage: UIImage(systemName: "person.2.fill"))
        
        let my = MyViewController()
        //let nav3 = UINavigationController(rootViewController: my)
        my.tabBarItem = UITabBarItem(title: "마이", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        setViewControllers([main,community,my], animated: true)
    }
}
