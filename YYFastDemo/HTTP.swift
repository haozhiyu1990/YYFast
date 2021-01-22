//
//  HTTP.swift
//  YYFastDemo
//
//  Created by 7080 on 2021/1/22.
//  Copyright © 2021 haozhiyu. All rights reserved.
//

import UIKit
import Moya
import Alamofire
import CleanJSON

let networkPlugin = NetworkActivityPlugin { (networkActivityChangeType, _) in
    switch networkActivityChangeType {
    case .began:
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    case .ended:
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

class MyHomeHttp {
    enum Result<Success, Failure> where Failure: Error {
        case success(Success)
        case failure(Failure)
    }
    
    struct MHError: Error {
        var errorCode: Int?
        var message: String
    }
    
    @discardableResult
    class func loadData<T: TargetType, M: Decodable>(Model: M.Type, API: T.Type, target: T, using: JSONDecoder = CleanJSONDecoder(), progress: ((Double) -> Void)? = nil, completion: @escaping ((MyHomeHttp.Result<M, MyHomeHttp.MHError>) -> Void)) -> Cancellable? {
        
        if let isReachable = NetworkReachabilityManager()?.isReachable, isReachable == false {
            completion(.failure(MHError(errorCode: nil, message: "网络异常")))
            YYHUD.show(text: "网络异常")
            return nil
        }
        
//        let provider = MoyaProvider<T>(plugins: [RequestHandlingPlugin(), networkPlugin])
        
        // 设置网络请求超时
        let requsetClosure = { (endpoint: Endpoint, closure: MoyaProvider<T>.RequestResultClosure) in
            do {
                var urlRequest = try endpoint.urlRequest()
                urlRequest.timeoutInterval = 15
                closure(.success(urlRequest))
            } catch MoyaError.requestMapping(let url) {
                closure(.failure(MoyaError.requestMapping(url)))
            } catch MoyaError.parameterEncoding(let error) {
                closure(.failure(MoyaError.parameterEncoding(error)))
            } catch {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
        let provider = MoyaProvider<T>(requestClosure: requsetClosure, plugins: [RequestHandlingPlugin(), networkPlugin])
        let cancellable = provider.request(target, progress: { progressT in
            progress?(progressT.progress)
        }) { result in
            switch result {
            case let .success(response):
                guard let model = try? response.map(BaseModel.self, using: using) else {
                    failureHandle(completion: completion , stateCode: nil, message: "数据解析失败")
                    return
                }
                guard model.success else {
                    failureHandle(completion: completion , stateCode: model.status, message: model.error)
                    return
                }
                guard model.code != 99996 else {
                    failureHandle(completion: completion , stateCode: nil, message: "token异常")
                    return
                }
                guard let dataModel = try? response.map(Model, using: using) else {
                    failureHandle(completion: completion , stateCode: nil, message: "数据解析失败")
                    return
                }
                completion(.success(dataModel))
            case let .failure(error):
                //请求数据失败，可能是404（无法找到指定位置的资源），408（请求超时）等错误
                //可百度查找“http状态码”
                let statusCode = error.response?.statusCode
                let errorMessage = error.response?.description ?? "未知错误"
                failureHandle(completion: completion, stateCode: statusCode, message: errorMessage)
            }
        }
        
        //错误处理 - 弹出错误信息
        func failureHandle(completion: ((MyHomeHttp.Result<M, MyHomeHttp.MHError>) -> Void) , stateCode: Int?, message: String) {
            YYHUD.show(text: message)
            completion(.failure(MHError(errorCode: stateCode, message: message)))
        }
        
        return cancellable
    }
}
