//
//  YYEnum.swift
//  YYFastDemo
//
//  Created by 7080 on 2021/1/22.
//  Copyright © 2021 haozhiyu. All rights reserved.
//

enum ValueItem {
    case top
    case bottom
    case left
    case right
    case centerX
    case centerY
    case width
    case height
}

enum PointItem {
    case center
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

enum MakerItem {
    case valueItem([ValueItem])
    case pointItem([PointItem])
    case size
    case frame
}

extension MakerItem: Equatable {
    static func == (lhs: MakerItem, rhs: MakerItem) -> Bool {
        switch (lhs, rhs) {
        case (.size, .size),
             (.frame, .frame):
            return true
        case (.valueItem(let item1), .valueItem(let item2)):
            return item1.description == item2.description
        case (.pointItem(let item1), .pointItem(let item2)):
            return item1.description == item2.description
        default:
            return false
        }
    }
}
