//
//  API.swift
//  YYFastDemo
//
//  Created by 7080 on 2021/1/22.
//  Copyright © 2021 haozhiyu. All rights reserved.
//

import UIKit
import Moya

let hostIP = "hostip"

// --- 公共参数 ----
class RequestHandlingPlugin: PluginType {
    /// Called to modify a request before sending
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutateableRequest = request
        return mutateableRequest.appendCommonParams();
    }
}

extension URLRequest {
    /// global common params
    private var commonParams: [String: Any] {
        //所有接口的公共参数添加在这里
        return [:]
    }
    
    mutating func appendCommonParams() -> URLRequest {
        let request = try? encoded(parameters: commonParams, parameterEncoding: URLEncoding(destination: .queryString))
        assert(request != nil, "append common params failed, please check common params value")
        return request!
    }
    
    func encoded(parameters: [String: Any], parameterEncoding: ParameterEncoding) throws -> URLRequest {
        do {
            return try parameterEncoding.encode(self, with: parameters)
        } catch {
            throw MoyaError.parameterEncoding(error)
        }
    }
}

// --- 公共参数end ----

//TargetType协议可以一次性处理的参数
public extension TargetType {
    var baseURL: URL {
        return URL(string: hostIP)!
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
}

enum  API {
    /// 获取活动账单
    case getDiscountBill(num: String)
    /// 获取活动子账单
    case getDiscountChildBill(num: String, parentNum: String)
    case downloadFile
}

extension API: TargetType {
    var method: Moya.Method {
        switch self {
        case .getDiscountBill:
            return .get
        case .getDiscountChildBill:
            return .get
        default:
            return .post
        }
    }
    var path: String {
        switch self {
        case .getDiscountBill:
            return "/app/activity/get/activity/bill"
        case .getDiscountChildBill:
            return "/app/activity/get/child/bill"
        case .downloadFile:
            return ""
        }
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case let .getDiscountBill(num):
            params["activityNumber"] = num
        case let .getDiscountChildBill(num, parentNum):
            params["activityNumber"] = num
            params["parentBill"] = parentNum
        default:
            return .requestPlain
        }
        //Task是一个枚举值，根据后台需要的数据，选择不同的http task。
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
}
