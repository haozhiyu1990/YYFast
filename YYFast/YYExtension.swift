//
//  YYExtension.swift
//  YYProject
//
//  Created by haozhiyu on 2019/1/15.
//  Copyright © 2019 haozhiyu. All rights reserved.
//

import UIKit

public let KEYSCREEN_W = UIScreen.main.bounds.width
public let KEYSCREEN_H = UIScreen.main.bounds.height

public func RGB(_ red: CGFloat,_ green: CGFloat,_ blue: CGFloat,_ alpha: CGFloat = 1) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}

extension UIDevice {
    public func isX() -> Bool {
        guard #available(iOS 11.0, *) else {
            return false
        }
        return UIApplication.shared.windows[0].safeAreaInsets.bottom > 0
    }
}

extension UIColor {
    public class func colorWithHexString(hex: String) -> UIColor {
        
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            let index = cString.index(cString.startIndex, offsetBy:1)
            cString = String(cString[index...])
        }
        
        if (cString.count != 6) {
            return UIColor.red
        }
        
        let rIndex = cString.index(cString.startIndex, offsetBy: 2)
        let rString = cString[..<rIndex]
        
        let otherString = cString[rIndex...]
        
        let gIndex = otherString.index(otherString.startIndex, offsetBy: 2)
        let gString = otherString[..<gIndex]
        
        let bIndex = cString.index(cString.endIndex, offsetBy: -2)
        let bString = cString[bIndex...]
        
        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0;
        Scanner(string: String(rString)).scanHexInt32(&r)
        Scanner(string: String(gString)).scanHexInt32(&g)
        Scanner(string: String(bString)).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

extension NSObject {
    public var currentVC: UIViewController? {
        var result: UIViewController?
        
        let tmpWindow = UIApplication.shared.keyWindow
        guard var window = tmpWindow else {
            return result
        }
        
        if window.windowLevel != .normal {
            for win in UIApplication.shared.windows {
                if win.windowLevel == .normal {
                    window = win
                    break
                }
            }
        }
        
        var next: UIResponder?
        
        if let rootVC = window.rootViewController {
            if let presentVC = rootVC.presentedViewController {
                next = presentVC
            } else {
                let view = window.subviews[0]
                next = view.next
            }
        }
        
        repeat {
            if next is UITabBarController {
                let tabBar = next as! UITabBarController
                let nav = tabBar.selectedViewController as! UINavigationController
                result = nav.viewControllers.last
                
                return result
            } else if next is UINavigationController {
                let nav = next as! UINavigationController
                result = nav.viewControllers.last
                
                return result
            } else if next is UIViewController {
                result = next as? UIViewController
                
                return result
            }
            next = next?.next
        } while(next != nil)
        
        return result
    }
}
