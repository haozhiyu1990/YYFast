//
//  BaseModel.swift
//  YYFastDemo
//
//  Created by 7080 on 2021/1/22.
//  Copyright © 2021 haozhiyu. All rights reserved.
//

struct BaseModel: Codable {
    var code: Int
    var status: Int
    var error: String
    var message: String
    var success: Bool
}
