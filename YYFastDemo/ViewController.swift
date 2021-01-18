//
//  ViewController.swift
//  YYFastDemo
//
//  Created by haozhiyu on 2019/1/15.
//  Copyright © 2019 haozhiyu. All rights reserved.
//

import UIKit
import YYFast

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarDidChangeFrame(_:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
        print(UIDevice.isX())

        YYLocationManager.shared.startLocation {
            print(YYLocationManager.shared.address ?? "")
            print(YYLocationManager.shared.latitude ?? "")
            print(YYLocationManager.shared.longitude ?? "")
        }
        kSafeAreaInsets
    }
    
    @objc func statusBarDidChangeFrame(_ not: Notification) {
        print(UIApplication.shared.windows[0].safeAreaInsets)
    }
}

