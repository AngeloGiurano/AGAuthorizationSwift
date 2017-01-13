//
//  HTTPClient.swift
//  Authorization
//
//  Created by Angelo Giurano on 9/20/16.
//  Copyright © 2016 OpsTalent. All rights reserved.
//
import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import PromiseKit
import KeychainAccess

private class APIResponse<T : Mappable>: Mappable {
    var success: Bool = false
    var data: T?
    var error : APIError?
    
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        success <- map["success"]
        data <- map["data"]
        error <- map["error"]
    }
}

enum APIError: Error {
    case unAuthorizedError(String)
}


public class HTTPClient : NSObject {
    static let sharedInstance = HTTPClient()
    
    
    //MARK: Helper functions
    func post<T : Mappable>(_ route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperation(method: .post, route: route, parameters: parameters)
    }
    
    func unauthorizedPost<T: Mappable>(_ route: RouterType, parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperationUnauthorized(.post, route: route, parameters: parameters)
    }
    
    
    func post(_ route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<Void> {
        return self.httpOperationVoid(.post, route: route, parameters: parameters)
    }
    
    func get<T: Mappable>(_ route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperation(method: .get, route: route, parameters : parameters);
    }
    
    func get(_ route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<Void> {
        return self.httpOperationVoid(.get, route: route, parameters : parameters);
    }
    
    func getList<T: Mappable>(_ route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<[T]> {
        return self.httpOperationList(.get, route: route, parameters: parameters)
    }
    
    func delete<T: Mappable>(_ route: RouterType, parameters: [String: AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperation(method: .delete, route: route, parameters: parameters)
    }
    
    
    func delete(_ route: Router, parameters: [String: AnyObject]? = nil) -> Promise<Void> {
        return self.httpOperationVoid(.delete, route: route, parameters: parameters)
    }
    
    func put<T: Mappable>(_ route: RouterType, parameters: [String: AnyObject]? = nil) -> Promise<T?> {
        return self.httpOperation(method: .put, route: route, parameters: parameters)
    }
    
    fileprivate func httpOperation<T : Mappable>(method : HTTPMethod, route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        
        
        return Promise<T?> { (fulfill, reject) -> Void in
            
            AuthorizationService.sharedInstance.getValidToken()
                .then {
                    _ -> Void in
                    
                    guard let tokenHeader = AuthorizationService.token_header else {
                        reject(APIError.unAuthorizedError("Unauthorized"))
                        return
                    }
                    
                    func parsingError(_ erroString : String) -> NSError {
                        return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
                    }
                    
                    var encoding: ParameterEncoding = URLEncoding.queryString
                    
                    switch method {
                    case .post:
                        encoding = JSONEncoding.default
                    case .get:
                        encoding = URLEncoding.queryString
                    case .delete:
                        encoding = URLEncoding.default
                    case .put:
                        encoding = JSONEncoding.default
                    default:
                        break
                    }
                    
                    request(route.URLString, method: method, parameters: parameters, encoding: encoding, headers: tokenHeader)
                        .responseJSON { (response) -> Void in
                            
                            if let error = response.result.error {
                                reject(error) //network error
                            }else {
                                if let apiResponse = Mapper<T>().map(JSON: response.result.value as! [String : Any]) {
                                    fulfill(apiResponse)
                                } else{
                                    let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
                                    reject(err)
                                }
                            }
                            
                    }
            }
        }
    }
    
    //    private func httpOperationList<T : Mappable>(method : Alamofire.Method, route : RouterType, let parameters : [String : AnyObject]? = nil) -> Promise<CountReply<T>> {
    //
    //        return Promise<CountReply<T>> { (fulfill, reject) -> Void in
    //
    //            AuthorizationService.sharedInstance.getValidToken()
    //            .then {
    //                _ -> Void in
    //
    //                guard let tokenHeader = AuthorizationService.token_header else {
    //                    reject(APIError.unAuthorizedError("Unauthorized"))
    //                    return
    //                }
    //
    //                func parsingError(erroString : String) -> NSError {
    //                    return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
    //                }
    //
    //                var encoding: ParameterEncoding = .URLEncodedInURL
    //
    //                switch method {
    //                case .POST:
    //                    encoding = ParameterEncoding.JSON
    //                case .GET:
    //                    encoding = ParameterEncoding.URLEncodedInURL
    //                default:
    //                    break
    //                }
    //
    //                request(method, route.URLString, parameters: parameters, encoding: encoding, headers: tokenHeader)
    //                .responseJSON { (response) -> Void in
    //
    //                    if let error = response.result.error {
    //                        reject(error) //network error
    //                    }else {
    //                        if let apiResponse = Mapper<CountReply<T>>().map(response.result.value) {
    //                            if apiResponse.success {
    //                                fulfill(apiResponse)
    //                            }else{
    //                                if let _ = apiResponse.error {
    //                                    reject(APIError.unAuthorizedError("UNauthorized"))
    //                                }else{
    //                                    reject(APIError.unAuthorizedError("UNauthorized"))
    //                                }
    //                            }
    //                        }else{
    //                            let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
    //                            reject(err)
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    fileprivate func httpOperationList<T : Mappable>(_ method : HTTPMethod, route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<[T]> {
        
        return Promise<[T]> { (fulfill, reject) -> Void in
            
            AuthorizationService.sharedInstance.getValidToken()
                .then {
                    _ -> Void in
                    
                    guard let tokenHeader = AuthorizationService.token_header else {
                        reject(APIError.unAuthorizedError("Unauthorized"))
                        return
                    }
                    
                    func parsingError(_ erroString : String) -> NSError {
                        return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
                    }
                    
                    var encoding: ParameterEncoding = URLEncoding.queryString
                    
                    switch method {
                    case .post:
                        encoding = JSONEncoding.default
                    case .get:
                        encoding = URLEncoding.queryString
                    default:
                        break
                    }
                    
                    Alamofire.request(route.URLString, method: method, parameters: parameters, encoding: encoding, headers: tokenHeader)
                        .validate()
                        .responseArray { (response: DataResponse<[T]>) in
                            if let apiResponse = response.result.value {
                                fulfill(apiResponse)
                                return
                            }
                            
                            if let error = response.result.error {
                                reject(error)
                                return
                            }
                    }
            }
        }
    }
    
    
    fileprivate func httpOperationVoid(_ method : HTTPMethod, route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<Void> {
        
        
        return Promise<Void> { (fulfill, reject) -> Void in
            
            AuthorizationService.sharedInstance.getValidToken()
                .then {
                    _ -> Void in
                    
                    guard let tokenHeader = AuthorizationService.token_header else {
                        reject(APIError.unAuthorizedError("Unauthorized"))
                        return
                    }
                    
                    func parsingError(_ erroString : String) -> NSError {
                        return NSError(domain: "com.wallbrand.error", code: -100, userInfo: nil)
                    }
                    
                    var encoding: ParameterEncoding = URLEncoding.queryString
                    
                    switch method {
                    case .post:
                        encoding = JSONEncoding.default
                    case .get:
                        encoding = URLEncoding.queryString
                    case .delete:
                        encoding = URLEncoding.default
                    case .put:
                        encoding = JSONEncoding.default
                    default:
                        break
                    }
                    
                    request(route.URLString, method: method, parameters: parameters, encoding: encoding, headers: tokenHeader)
                        .responseJSON { (response) -> Void in
                            
                            if response.response?.statusCode == 200 {
                                fulfill()
                            } else {
                                reject(APIError.unAuthorizedError("Unauthorized"))
                            }
                    }
            }
        }
    }
    
    
    
    
    fileprivate func httpOperationUnauthorized<T: Mappable>(_ method : HTTPMethod, route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<T?> {
        
        
        return Promise<T?> { (fulfill, reject) -> Void in
            
            func parsingError(_ erroString : String) -> NSError {
                return NSError(domain: "com.paychores.com", code: -100, userInfo: nil)
            }
            
            var encoding: ParameterEncoding = URLEncoding.queryString
            
            switch method {
            case .post:
                encoding = JSONEncoding.default
            case .get:
                encoding = URLEncoding.queryString
            case .delete:
                encoding = URLEncoding.default
            case .put:
                encoding = JSONEncoding.default
            default:
                break
            }
            
            request(route.URLString, method: method, parameters: parameters, encoding: encoding, headers: nil)
                .responseJSON { (response) -> Void in
                    
                    if let error = response.result.error {
                        reject(error) //network error
                    }else {
                        if let apiResponse = Mapper<T>().map(JSON: response.result.value as! [String : Any]) {
                            fulfill(apiResponse)
                        }else{
                            let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
                            reject(err)
                        }
                    }
                    
            }
        }
    }
    
    
    func uploadFile(withData data: NSData, route : RouterType, parameters : [String : AnyObject]? = nil) -> Promise<File?> {
        return Promise<File?> {
            fulfill, reject in
            AuthorizationService.sharedInstance.getValidToken()
                .then {
                _ -> Void in
                
                guard let tokenHeader = AuthorizationService.token_header else {
                    reject(APIError.unAuthorizedError("Unauthorized"))
                    return
                }
                
                    
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(data as Data, withName: "file[file]", fileName: "image.png", mimeType: "image/png")
                }, usingThreshold: UInt64.init(100), to: route.URLString, method: .post, headers: tokenHeader, encodingCompletion: { (encodingCompletionResult) in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    switch encodingCompletionResult {
                    case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                        upload.responseObject { response in
                            fulfill(response.result.value)
                        }
                    case .failure(let error):
                        reject(error)
                    }
                })
                
            }
        }
    }
}
