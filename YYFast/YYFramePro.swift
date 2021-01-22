//
//  YYFramePro.swift
//  YYFastDemo
//
//  Created by 7080 on 2021/1/22.
//  Copyright © 2021 haozhiyu. All rights reserved.
//

import UIKit

public final class YYFramePro<Base> {
    let maker: Maker<Base>
    init(base b: Base) {
        maker = Maker(base: b)
    }
}

public class Maker<Base> {
    var valueItems: [ValueItem] = []
    var pointItems: [PointItem] = []
    var sizeItems: [MakerItem] = []
    var frameItems: [MakerItem] = []

    let base: Base
    init(base b: Base) {
        base = b
    }
}

extension YYFramePro where Base: UIView {
    public func makeFrame(_ make: ((Maker<Base>) -> Void)) {
        make(maker)
    }
    
    public var x: CGFloat {
        return maker.base.frame.minX
    }
    public var y: CGFloat {
        return maker.base.frame.minY
    }
    
    public var top: CGFloat {
        return maker.base.frame.minY
    }
    public var bottom: CGFloat {
        return maker.base.frame.maxY
    }
    public var left: CGFloat {
        return maker.base.frame.minX
    }
    public var right: CGFloat {
        return maker.base.frame.maxX
    }
    
    public var width: CGFloat {
        return maker.base.frame.width
    }
    public var height: CGFloat {
        return maker.base.frame.height
    }
    
    public var center: CGPoint {
        return maker.base.center
    }
    public var centerX: CGFloat {
        return maker.base.frame.midX
    }
    public var centerY: CGFloat {
        return maker.base.frame.midY
    }
    
    public var topLeft: CGPoint {
        return CGPoint(x: left, y: top)
    }
    public var topRight: CGPoint {
        return CGPoint(x: right, y: top)
    }
    public var bottomLeft: CGPoint {
        return CGPoint(x: left, y: bottom)
    }
    public var bottomRight: CGPoint {
        return CGPoint(x: right, y: bottom)
    }
    
    public var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    public var frame: CGRect {
        return maker.base.frame
    }
}

extension Maker where Base: UIView {
    var valueKey: String {
        return "valuekey"
    }
    var pointKey: String {
        return "pointkey"
    }
    var sizeKey: String {
        return "sizekey"
    }
    var frameKey: String {
        return "framekey"
    }
    
    func changeValue(changItem: ValueItem, value: CGFloat) {
        switch changItem {
        case .top:
            base.frame.origin.y = value
        case .bottom:
            base.frame.origin.y = value-base.jy.height
        case .left:
            base.frame.origin.x = value
        case .right:
            base.frame.origin.x = value-base.jy.width
        case .centerX:
            base.frame.origin.x = value-base.jy.width/2
        case .centerY:
            base.frame.origin.y = value-base.jy.height/2
        case .width:
            base.frame.size.width = value
        case .height:
            base.frame.size.height = value
        }
    }
    
    func changePoint(changItem: PointItem, point: CGPoint) {
        switch changItem {
        case .center:
            base.center = point
        case .topLeft:
            base.frame.origin.x = point.x
            base.frame.origin.y = point.y
        case .topRight:
            base.frame.origin.x = point.x-base.jy.width
            base.frame.origin.y = point.y
        case .bottomLeft:
            base.frame.origin.x = point.x
            base.frame.origin.y = point.y-base.jy.height
        case .bottomRight:
            base.frame.origin.x = point.x-base.jy.width
            base.frame.origin.y = point.y-base.jy.height
        }
    }
    
    func changeSize(changItem: MakerItem, size: CGSize) {
        base.frame.size = size
    }
    
    func changeFrame(changItem: MakerItem, frame: CGRect) {
        base.frame = frame
    }
    
    func changFrame(_ changItem: [String : MakerItem],_ changValue: ValuePro) {
        if let value = changValue.value {
            let makerItem = changItem[valueKey]
            if case let .valueItem(items) = makerItem {
                for item in items {
                    changeValue(changItem: item, value: value)
                }
            }
        }
        if let point = changValue.point {
            let makerItem = changItem[pointKey]
            if case let .pointItem(items) = makerItem {
                for item in items {
                    changePoint(changItem: item, point: point)
                }
            }
        }
        if let size = changValue.size {
            if let makerItem = changItem[sizeKey] {
                if case .size = makerItem {
                    changeSize(changItem: makerItem, size: size)
                }
            }
        }
        if let rect = changValue.rect {
            if let makerItem = changItem[frameKey] {
                if case .frame = makerItem {
                    changeFrame(changItem: makerItem, frame: rect)
                }
            }
        }
    }
    
    public func value(_ value: ValuePro) {
        var changeds: [String : MakerItem] = [:]
        changeds.updateValue(.valueItem(valueItems.deduplicates), forKey: valueKey)
        changeds.updateValue(.pointItem(pointItems.deduplicates), forKey: pointKey)
        if let size = sizeItems.filterDeduplicates({ $0 }).first {
            changeds.updateValue(size, forKey: sizeKey)
        }
        if let frame = frameItems.filterDeduplicates({ $0 }).first {
            changeds.updateValue(frame, forKey: frameKey)
        }
        
        valueItems.removeAll()
        pointItems.removeAll()
        sizeItems.removeAll()
        frameItems.removeAll()
        
        changFrame(changeds, value)
    }
    
    public var top: Maker {
        valueItems.append(.top)
        return self
    }
    public var bottom: Maker {
        valueItems.append(.bottom)
        return self
    }
    public var left: Maker {
        valueItems.append(.left)
        return self
    }
    public var right: Maker {
        valueItems.append(.right)
        return self
    }
    
    public var width: Maker {
        valueItems.append(.width)
        return self
    }
    public var height: Maker {
        valueItems.append(.height)
        return self
    }
    
    public var center: Maker {
        pointItems.append(.center)
        return self
    }
    public var centerX: Maker {
        valueItems.append(.centerX)
        return self
    }
    public var centerY: Maker {
        valueItems.append(.centerY)
        return self
    }
    
    public var topLeft: Maker {
        pointItems.append(.topLeft)
        return self
    }
    public var topRight: Maker {
        pointItems.append(.topRight)
        return self
    }
    public var bottomLeft: Maker {
        pointItems.append(.bottomLeft)
        return self
    }
    public var bottomRight: Maker {
        pointItems.append(.bottomRight)
        return self
    }
    
    public var size: Maker {
        sizeItems.append(.size)
        return self
    }
    
    public var frame: Maker {
        frameItems.append(.frame)
        return self
    }
}
