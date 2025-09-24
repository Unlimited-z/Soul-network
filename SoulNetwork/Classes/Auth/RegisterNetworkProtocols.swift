//
//  RegisterNetworkProtocols.swift
//  SoulNetwork
//
//  Created by Ricard.li on 2025/1/24.
//

import Foundation
import UIKit

// MARK: - 注册响应模型
public struct RegisterResponse: Codable {
    public let success: Bool
    public let message: String?
    public let data: RegisterData?
    public let code: Int?
    
    public init(success: Bool, message: String?, data: RegisterData?, code: Int?) {
        self.success = success
        self.message = message
        self.data = data
        self.code = code
    }
}

public struct RegisterData: Codable {
    public let userId: String
    public let phone: String?
    public let email: String?
    public let token: String?
    public let needCompleteProfile: Bool? // 是否需要完善资料
    public let registrationStep: String? // 注册步骤：phone_verified, email_verified, profile_completed
    
    public init(userId: String, phone: String?, email: String?, token: String?, needCompleteProfile: Bool?, registrationStep: String?) {
        self.userId = userId
        self.phone = phone
        self.email = email
        self.token = token
        self.needCompleteProfile = needCompleteProfile
        self.registrationStep = registrationStep
    }
}

// MARK: - 检查手机号/邮箱是否可用响应模型
public struct CheckAvailabilityResponse: Codable {
    public let success: Bool
    public let message: String?
    public let data: CheckAvailabilityData?
    public let code: Int?
    
    public init(success: Bool, message: String?, data: CheckAvailabilityData?, code: Int?) {
        self.success = success
        self.message = message
        self.data = data
        self.code = code
    }
}

public struct CheckAvailabilityData: Codable {
    public let available: Bool
    public let reason: String? // 不可用的原因
    public let suggestions: [String]? // 建议的替代方案
    
    public init(available: Bool, reason: String?, suggestions: [String]?) {
        self.available = available
        self.reason = reason
        self.suggestions = suggestions
    }
}

// MARK: - 手机号注册协议
public class SoulPhoneRegisterProtocol: SoulBaseNetworkProtocol {
    public var phone: String = ""
    public var password: String = ""
    public var verificationCode: String = ""
    public var codeId: String = "" // 验证码ID
    public var areaCode: String = "86"
    public var nickname: String? = nil
    public var inviteCode: String? = nil // 邀请码
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/register/phone"
    }
    
    public override func getParameters() -> [String: Any] {
        var params: [String: Any] = [
            "phone": phone,
            "password": password,
            "verificationCode": verificationCode,
            "codeId": codeId,
            "areaCode": areaCode,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "platform": "iOS",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        ]
        
        if let nickname = nickname {
            params["nickname"] = nickname
        }
        
        if let inviteCode = inviteCode {
            params["inviteCode"] = inviteCode
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

// MARK: - 邮箱注册协议
public class SoulEmailRegisterProtocol: SoulBaseNetworkProtocol {
    public var email: String = ""
    public var password: String = ""
    public var verificationCode: String = ""
    public var codeId: String = ""
    public var nickname: String? = nil
    public var inviteCode: String? = nil
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/register/email"
    }
    
    public override func getParameters() -> [String: Any] {
        var params: [String: Any] = [
            "email": email,
            "password": password,
            "verificationCode": verificationCode,
            "codeId": codeId,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "platform": "iOS",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        ]
        
        if let nickname = nickname {
            params["nickname"] = nickname
        }
        
        if let inviteCode = inviteCode {
            params["inviteCode"] = inviteCode
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

// MARK: - 发送注册验证码协议
public class SoulSendRegisterCodeProtocol: SoulBaseNetworkProtocol {
    public var phone: String? = nil
    public var email: String? = nil
    public var areaCode: String = "86"
    public var codeType: String = "register"
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/send-code"
    }
    
    public override func getParameters() -> [String: Any] {
        var params: [String: Any] = [
            "codeType": codeType,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        
        if let phone = phone {
            params["phone"] = phone
            params["areaCode"] = areaCode
        }
        
        if let email = email {
            params["email"] = email
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

// MARK: - 检查手机号是否可用协议
public class SoulCheckPhoneAvailabilityProtocol: SoulBaseNetworkProtocol {
    public var phone: String = ""
    public var areaCode: String = "86"
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/check-phone"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "phone": phone,
            "areaCode": areaCode
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
        return "GET"
    }
}

// MARK: - 检查邮箱是否可用协议
public class SoulCheckEmailAvailabilityProtocol: SoulBaseNetworkProtocol {
    public var email: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/check-email"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "email": email
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
        return "GET"
    }
}

// MARK: - 检查昵称是否可用协议
public class SoulCheckNicknameAvailabilityProtocol: SoulBaseNetworkProtocol {
    public var nickname: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/check-nickname"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "nickname": nickname
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
        return "GET"
    }
}

// MARK: - 验证邀请码协议
public class SoulVerifyInviteCodeProtocol: SoulBaseNetworkProtocol {
    public var inviteCode: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/verify-invite-code"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "inviteCode": inviteCode
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
        return "GET"
    }
}

// MARK: - 完善用户资料协议
public class SoulCompleteProfileProtocol: SoulBaseNetworkProtocol {
    public var token: String = ""
    public var nickname: String? = nil
    public var avatar: String? = nil // 头像URL或base64
    public var gender: Int? = nil // 0: 未知, 1: 男, 2: 女
    public var birthday: String? = nil // YYYY-MM-DD
    public var location: String? = nil
    public var signature: String? = nil
    public var interests: [String]? = nil // 兴趣标签
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/complete-profile"
    }
    
    public override func getParameters() -> [String: Any] {
        var params: [String: Any] = [:]
        
        if let nickname = nickname {
            params["nickname"] = nickname
        }
        
        if let avatar = avatar {
            params["avatar"] = avatar
        }
        
        if let gender = gender {
            params["gender"] = gender
        }
        
        if let birthday = birthday {
            params["birthday"] = birthday
        }
        
        if let location = location {
            params["location"] = location
        }
        
        if let signature = signature {
            params["signature"] = signature
        }
        
        if let interests = interests {
            params["interests"] = interests
        }
        
        return params
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

// MARK: - 重置密码协议
public class SoulResetPasswordProtocol: SoulBaseNetworkProtocol {
    public var phone: String? = nil
    public var email: String? = nil
    public var verificationCode: String = ""
    public var codeId: String = ""
    public var newPassword: String = ""
    public var areaCode: String = "86"
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/reset-password"
    }
    
    public override func getParameters() -> [String: Any] {
        var params: [String: Any] = [
            "verificationCode": verificationCode,
            "codeId": codeId,
            "newPassword": newPassword,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        
        if let phone = phone {
            params["phone"] = phone
            params["areaCode"] = areaCode
        }
        
        if let email = email {
            params["email"] = email
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

// MARK: - 发送重置密码验证码协议
public class SoulSendResetPasswordCodeProtocol: SoulBaseNetworkProtocol {
    public var phone: String? = nil
    public var email: String? = nil
    public var areaCode: String = "86"
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "https://api.soul.com/v1/auth/send-reset-code"
    }
    
    public override func getParameters() -> [String: Any] {
        var params: [String: Any] = [
            "codeType": "reset",
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        
        if let phone = phone {
            params["phone"] = phone
            params["areaCode"] = areaCode
        }
        
        if let email = email {
            params["email"] = email
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