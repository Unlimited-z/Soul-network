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
    public let code: Int
    public let data: String?
    public let msg: String?
    
    public init(code: Int, data: String?, msg: String?) {
        self.code = code
        self.data = data
        self.msg = msg
    }
}

// MARK: - 用户登录协议
public class SoulUserLoginProtocol: SoulBaseNetworkProtocol {
    public var username: String = ""
    public var password: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "http://47.94.84.165:8080/community/user/login"
    }
    
    public override func getParameters() -> [String: Any] {
        return [
            "username": username,
            "password": password
        ]
    }
    
    public override func getHeaders() -> [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    public override func getHttpMethod() -> String {
        return "POST"
    }
}