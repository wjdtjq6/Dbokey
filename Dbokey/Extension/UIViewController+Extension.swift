//
//  UIViewController+Extension.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import UIKit

extension UIViewController {
    
    func setRootViewController(_ viewController: UIViewController) {
 
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
        let window = scene.window {
             
            window.rootViewController = viewController
            
            UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        }
        
    }
    
}
