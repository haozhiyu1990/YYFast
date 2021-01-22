//
//  YYProtocol.swift
//  YYFastDemo
//
//  Created by 7080 on 2021/1/22.
//  Copyright © 2021 haozhiyu. All rights reserved.
//

import UIKit

public protocol YYViewPro {
    associatedtype ComplentType
    var jy: ComplentType { get }
}

extension YYViewPro {
    public var jy: YYFramePro<Self> {
        return YYFramePro(base: self)
    }
}

extension UIView: YYViewPro { }

public protocol ValuePro {
    var value: CGFloat? { get }
    var point: CGPoint? { get }
    var size: CGSize? { get }
    var rect: CGRect? { get }
}

extension ValuePro {
    public var value: CGFloat? {
        return nil
    }
    public var point: CGPoint? {
        return nil
    }
    public var size: CGSize? {
        return nil
    }
    public var rect: CGRect? {
        return nil
    }
}

extension Int: ValuePro {
    public var value: CGFloat? {
        return CGFloat(self)
    }
}
extension Float: ValuePro {
    public var value: CGFloat? {
        return CGFloat(self)
    }
}
extension Double: ValuePro {
    public var value: CGFloat? {
        return CGFloat(self)
    }
}
extension CGFloat: ValuePro {
    public var value: CGFloat? {
        return self
    }
}
extension CGPoint: ValuePro {
    public var point: CGPoint? {
        return self
    }
}
extension CGSize: ValuePro {
    public var size: CGSize? {
        return self
    }
}
extension CGRect: ValuePro {
    public var rect: CGRect? {
        return self
    }
}
