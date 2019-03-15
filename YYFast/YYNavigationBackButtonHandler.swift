//
//  YYNavigationBackButtonHandler.swift
//  YYFastDemo
//
//  Created by haozhiyu on 2019/3/15.
//  Copyright © 2019 haozhiyu. All rights reserved.
//

import UIKit

@objc protocol BackButtonHandlerProtocol {
    @objc optional func navigationShouldPopOnBackButton() -> Bool 
}

extension UIViewController: BackButtonHandlerProtocol {
    public func navigationShouldPopOnBackButton() -> Bool {
        return true
    }
}

extension UINavigationController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let count = navigationBar.items?.count, self.viewControllers.count < count {
            return true
        }
        var shouldPop = true
        if let vc = topViewController {
            shouldPop = vc.navigationShouldPopOnBackButton()
        }
        
        if shouldPop {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.popViewController(animated: true)
            }
        } else {
            for subView in navigationBar.subviews {
                if subView.alpha > 0 && subView.alpha < 1 {
                    UIView.animate(withDuration: 0.25) { 
                        subView.alpha = 1
                    }
                }
            }
        }
        return false
    }    
}
