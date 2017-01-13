
import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import KeychainAccess
import PromiseKit

enum GrantType: String {
    case password = "password"
    case clientCredentials = "client_credentials"
    case refreshToken = "refresh_token"
}

enum AuthErrorType: Error {
    case wrongPassword(message: String, code: Int?)
    case unAuthorized(message: String, code: Int?)
    case genericError(message: String)
    
    init(statusCode: Int?) {
        switch statusCode {
        case 400?:
            self = AuthErrorType.wrongPassword(message: "Wrong combination", code: statusCode)
        case 401?:
            self = AuthErrorType.unAuthorized(message: "Invalid access token", code: statusCode)
        default:
            self = AuthErrorType.genericError(message: "An error has occured")
        }
    }
}

final class AuthorizationService {
    
    static let sharedInstance = AuthorizationService()
    
    fileprivate init() {}
    
    static var token_header: [String: String]? {
        get {
            guard let token = Keychain.sharedInstance.accessToken else { return nil }
            return ["Authorization": "Bearer \(token)"]
        }
    }
    
    
    static var loginParameters: [String: String] {
        get {
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.password.rawValue]
            return parameters
        }
    }
    
    static var refreshTokenParameters: [String: String]? {
        get {
            guard let refreshToken = Keychain.sharedInstance.refreshToken else { return nil }
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.refreshToken.rawValue, CONSTANTS.AuthKeys.refreshTokenKey: refreshToken]
            return parameters
        }
    }
    
    static var registerParameters: [String: String] {
        get {
            let parameters: [String: String] = [CONSTANTS.AuthKeys.CLIENT_ID: CONSTANTS.client_id, CONSTANTS.AuthKeys.CLIENT_SECRET: CONSTANTS.client_secret, CONSTANTS.AuthKeys.GRANT_TYPE: GrantType.clientCredentials.rawValue]
            return parameters
        }
    }
    
    
    func login(withUsername username: String, andPassword password: String) -> Promise<OAuthResponse?> {
        var parameters = AuthorizationService.loginParameters
        parameters += ["username": username, "password": password]
        return HTTPClient.sharedInstance.unauthorizedPost(AuthRouter.login, parameters: parameters as [String : AnyObject]?)
    }
    
//    func register(form: RegisterForm, withToken token: String) -> Promise<User?> {
//        let parameters = ["user" : form.toJSON()]
//        return HTTPClient.sharedInstance.unauthorizedPost(AuthRouter.register(token), parameters: parameters)
//    }
    
    func getRegisterToken() -> Promise<String> {
        let parameters = AuthorizationService.registerParameters
        return getToken(AuthRouter.login, withParams: parameters as [String : AnyObject]?)
    }
    
    func getValidToken() -> Promise<OAuthResponse?> {
        let parameters = AuthorizationService.refreshTokenParameters
        return getValidToken(AuthRouter.refreshToken, withParams: parameters as [String : AnyObject]?)
    }
    
    
    fileprivate func getToken(_ route: RouterType, withParams parameters: [String: AnyObject]? = nil) -> Promise<String> {
        return Promise<String> { (fulfill, reject) -> Void in
            
            func parsingError(_ erroString : String) -> NSError {
                return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
            }
            
            let encoding: ParameterEncoding = URLEncoding.httpBody
            
            
            request(route.URLString, method: .post, parameters: parameters, encoding: encoding, headers: nil)
                .responseJSON { (response) -> Void in
                    
                    if let error = response.result.error {
                        reject(error) //network error
                    }else {
                        if let result = response.result.value as? [String: AnyObject], let accessToken = result[CONSTANTS.AuthKeys.accessTokenKey] as? String {
                            fulfill(accessToken)
                        }else{
                            let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
                            reject(err)
                        }
                    }
                    
            }
        }
    }
    
    fileprivate func getValidToken(_ route: RouterType, withParams parameters: [String: AnyObject]? = nil) -> Promise<OAuthResponse?> {
        return Promise<OAuthResponse?> { (fulfill, reject) -> Void in
            
            guard Keychain.sharedInstance.accessTokenIsExpired else {
                fulfill(OAuthResponse())
                return
            }
            
            func parsingError(_ erroString : String) -> NSError {
                return NSError(domain: "com.paychores.error", code: -100, userInfo: nil)
            }
            
            let encoding: ParameterEncoding = URLEncoding.httpBody
            
            
            request(route.URLString, method: .post, parameters: parameters, encoding: encoding, headers: nil)
                .responseJSON { (response) -> Void in
                    if let error = response.result.error {
                        reject(error) //network error
                    } else {
                        if let apiResponse = Mapper<OAuthResponse>().map(JSON: response.result.value as! [String : Any]) {
                            fulfill(apiResponse)
                        }else{
                            let err = NSError(domain: "com.paychores.error", code: -101, userInfo: nil)
                            reject(err)
                        }
                    }
            }
        }
    }
    
    func logout() {
        Keychain.sharedInstance.logOut()
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window!!.rootViewController = MainControllerManager.mainViewController
    }
}
