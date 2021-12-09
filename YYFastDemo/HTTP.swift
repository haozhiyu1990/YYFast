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
import YYFast

class YYNetworking: NSObject {
    enum Result<Success, Failure> where Failure: Error {
        case success(Success)
        case failure(Failure)
    }
    
    struct YYError: Error {
        var errorCode: Int?
        var message: String
    }
    
    /// 请求默认网络数据类型
    @discardableResult
    class func loadData<T: TargetType>(API: T.Type, target: T, using: JSONDecoder = CleanJSONDecoder(), cache: Bool = false, cacheHandle: ((BaseModel) -> Void)? = nil, progress: ((Double) -> Void)? = nil, completion: @escaping ((YYNetworking.Result<BaseModel, YYNetworking.YYError>) -> Void)) -> Cancellable? {
        loadData(Model: BaseModel.self, API: API, target: target, using: using, progress: progress, completion: completion)
    }
    
    /// 请求指定网络数据类型
    @discardableResult
    class func loadData<T: TargetType, M: Decodable>(Model: M.Type, API: T.Type, target: T, using: JSONDecoder = CleanJSONDecoder(), cache: Bool = false, cacheHandle: ((M) -> Void)? = nil, progress: ((Double) -> Void)? = nil, completion: @escaping ((YYNetworking.Result<M, YYNetworking.YYError>) -> Void)) -> Cancellable? {
            
        //如果需要读取缓存，则优先读取缓存内容
        if cache, let data = YYSaveFiles.read(path: target.path) {
            //cacheHandle不为nil则使用cacheHandle处理缓存，否则使用success处理
            if let block = cacheHandle {
                if let model = try? using.decode(Model, from: data) {
                    block(model)
                } else {
                    YYHUD.show()
                }
            }
        } else {
            //读取缓存速度较快，无需显示hud；仅从网络加载数据时，显示hud。
            YYHUD.show()
        }
        
        if let isReachable = NetworkReachabilityManager()?.isReachable, isReachable == false {
            YYHUD.hide()
            YYHUD.show(type: .error, text: "网络异常")
            completion(.failure(YYError(errorCode: nil, message: "网络异常")))
            return nil
        }
        
        let provider = MoyaProvider<T>(plugins: [RequestHandlingPlugin()])
        
        // 设置网络请求超时
//        let requsetClosure = { (endpoint: Endpoint, closure: MoyaProvider<T>.RequestResultClosure) in
//            do {
//                var urlRequest = try endpoint.urlRequest()
//                urlRequest.timeoutInterval = 100
//                closure(.success(urlRequest))
//            } catch MoyaError.requestMapping(let url) {
//                closure(.failure(MoyaError.requestMapping(url)))
//            } catch MoyaError.parameterEncoding(let error) {
//                closure(.failure(MoyaError.parameterEncoding(error)))
//            } catch {
//                closure(.failure(MoyaError.underlying(error, nil)))
//            }
//        }
//        let provider = MoyaProvider<T>(requestClosure: requsetClosure, plugins: [RequestHandlingPlugin()])
        let cancellable = provider.request(target, progress: { progressT in
            progress?(progressT.progress)
        }) { result in
            YYHUD.hide()
            switch result {
            case let .success(response):
                
                if let api = target as? API {
                    switch api {
                    case .downloadFile:
                        let model = try? response.map(Model, using: using)
                        successHandle(completion: completion, data: model)
                        return
                    default:
                        break
                    }
                }
                
                guard let model = try? response.map(BaseModel.self, using: using) else {
                    failureHandle(completion: completion , stateCode: nil, message: "数据解析失败")
                    return
                }
                
                guard model.code != 404 else {
                    failureHandle(completion: completion , stateCode: model.code, message: model.message)
                    return
                }
                
                guard let dataModel = try? response.map(Model, using: using) else {
                    failureHandle(completion: completion , stateCode: nil, message: "数据解析失败")
                    return
                }
                
                if cache {
                    //缓存
                    YYSaveFiles.save(path: target.path, data: response.data)
                }
                completion(.success(dataModel))
            case let .failure(error):
                
                //请求数据失败，可能是404（无法找到指定位置的资源），408（请求超时）等错误
                //可百度查找“http状态码”
                let statusCode = error.response?.statusCode
                let errorCode = "未知错误"
                failureHandle(completion: completion, stateCode: statusCode, message: error.errorDescription ?? errorCode)
            }
        }
        
        func successHandle(completion: ((YYNetworking.Result<M, YYNetworking.YYError>) -> Void), data: M?) {
            if let model = data {
                completion(.success(model))
            } else {
                completion(.success(BaseModel(code: 200, status: 200, error: "", message: "", success: true) as! M))
            }
        }
        
        //错误处理 - 弹出错误信息
        func failureHandle(completion: ((YYNetworking.Result<M, YYNetworking.YYError>) -> Void) , stateCode: Int?, message: String) {
            YYHUD.show(type: .error, text: message)
            completion(.failure(YYError(errorCode: stateCode, message: message)))
        }
        
        return cancellable
    }
}
