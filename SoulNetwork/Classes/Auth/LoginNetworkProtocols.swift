//
//  LoginNetworkProtocols.swift
//  SoulNetwork
//
//  Created by Ricard.li on 2025/1/24.
//

import Foundation
import UIKit

// MARK: - 登录响应模型
public struct LoginResponse: Codable {
    public let success: Bool
    public let message: String?
    public let data: LoginData?
    public let code: Int?
    
    public init(success: Bool, message: String?, data: LoginData?, code: Int?) {
        self.success = success
        self.message = message
        self.data = data
        self.code = code
    }
}

public struct LoginData: Codable {
    public let userId: String
    public let username: String?
    public let phone: String?
    public let email: String?
    public let avatar: String?
    public let token: String
    public let refreshToken: String?
    public let expiresIn: Int?
    public let userInfo: UserInfo?
    
    public init(userId: String, username: String?, phone: String?, email: String?, avatar: String?, token: String, refreshToken: String?, expiresIn: Int?, userInfo: UserInfo?) {
        self.userId = userId
        self.username = username
        self.phone = phone
        self.email = email
        self.avatar = avatar
        self.token = token
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.userInfo = userInfo
    }
}

public struct UserInfo: Codable {
    public let nickname: String?
    public let gender: Int? // 0: 未知, 1: 男, 2: 女
    public let birthday: String?
    public let location: String?
    public let signature: String?
    public let level: Int?
    public let points: Int?
    public let isVip: Bool?
    
    public init(nickname: String?, gender: Int?, birthday: String?, location: String?, signature: String?, level: Int?, points: Int?, isVip: Bool?) {
        self.nickname = nickname
        self.gender = gender
        self.birthday = birthday
        self.location = location
        self.signature = signature
        self.level = level
        self.points = points
        self.isVip = isVip
    }
}

// MARK: - 验证码响应模型
public struct VerificationCodeResponse: Codable {
    public let success: Bool
    public let message: String?
    public let code: Int?
    public let data: VerificationCodeData?
    
    public init(success: Bool, message: String?, code: Int?, data: VerificationCodeData?) {
        self.success = success
        self.message = message
        self.code = code
        self.data = data
    }
}

public struct VerificationCodeData: Codable {
    public let codeId: String
    public let expiresIn: Int // 验证码有效期（秒）
    
    public init(codeId: String, expiresIn: Int) {
        self.codeId = codeId
        self.expiresIn = expiresIn
    }
}

// MARK: - 手机号密码登录协议
public class SoulPhonePasswordLoginProtocol: SoulBaseNetworkProtocol {
    public var phone: String = ""
    public var password: String = ""
    public var areaCode: String = "86" // 默认中国区号
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/login/phone"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "phone": phone,
            "password": password,
            "areaCode": areaCode,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "platform": "iOS",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        ]
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "User-Agent": "Soul-iOS/1.0.0",
            "Accept": "application/json"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "POST"
    }
}

// MARK: - 手机号验证码登录协议
public class SoulPhoneCodeLoginProtocol: SoulBaseNetworkProtocol {
    public var phone: String = ""
    public var verificationCode: String = ""
    public var codeId: String = "" // 验证码ID
    public var areaCode: String = "86"
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/login/code"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "phone": phone,
            "verificationCode": verificationCode,
            "codeId": codeId,
            "areaCode": areaCode,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "platform": "iOS",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        ]
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "User-Agent": "Soul-iOS/1.0.0",
            "Accept": "application/json"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "POST"
    }
}

// MARK: - 发送登录验证码协议
public class SoulSendLoginCodeProtocol: SoulBaseNetworkProtocol {
    public var phone: String = ""
    public var areaCode: String = "86"
    public var codeType: String = "login" // login: 登录, register: 注册, reset: 重置密码
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/send-code"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "phone": phone,
            "areaCode": areaCode,
            "codeType": codeType,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "User-Agent": "Soul-iOS/1.0.0",
            "Accept": "application/json"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "POST"
    }
}

// MARK: - 邮箱登录协议
public class SoulEmailLoginProtocol: SoulBaseNetworkProtocol {
    public var email: String = ""
    public var password: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/login/email"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "email": email,
            "password": password,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "platform": "iOS",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        ]
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "User-Agent": "Soul-iOS/1.0.0",
            "Accept": "application/json"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "POST"
    }
}

// MARK: - 第三方登录协议（微信、QQ、微博等）
public class SoulThirdPartyLoginProtocol: SoulBaseNetworkProtocol {
    public var platform: String = "" // wechat, qq, weibo, apple
    public var accessToken: String = ""
    public var openId: String = ""
    public var unionId: String? = nil
    public var userInfo: [String: Any]? = nil
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/login/third-party"
    }
    
    public override func getParameters() -> [String: Any] {
        var params: [String: Any] = [
            "platform": platform,
            "accessToken": accessToken,
            "openId": openId,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "platform": "iOS",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        ]
        
        if let unionId = unionId {
            params["unionId"] = unionId
        }
        
        if let userInfo = userInfo {
            params["userInfo"] = userInfo
        }
        
        return params
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "User-Agent": "Soul-iOS/1.0.0",
            "Accept": "application/json"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "POST"
    }
}

// MARK: - 刷新Token协议
public class SoulRefreshTokenProtocol: SoulBaseNetworkProtocol {
    public var refreshToken: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/refresh-token"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "refreshToken": refreshToken,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "User-Agent": "Soul-iOS/1.0.0",
            "Accept": "application/json"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "POST"
    }
}

// MARK: - 登出协议
public class SoulLogoutProtocol: SoulBaseNetworkProtocol {
    public var token: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/logout"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "User-Agent": "Soul-iOS/1.0.0",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "POST"
    }
}

// MARK: - 检查登录状态协议
public class SoulCheckLoginStatusProtocol: SoulBaseNetworkProtocol {
    public var token: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/check-status"
    }
    
    public override func getParameters() -> [String: Any] {
        return [:]
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "User-Agent": "Soul-iOS/1.0.0",
            "Accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "GET"
    }
}