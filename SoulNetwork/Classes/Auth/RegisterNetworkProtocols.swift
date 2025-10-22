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
    public let code: Int
    public let data: String?
    public let msg: String?
    
    public init(code: Int, data: String?, msg: String?) {
        self.code = code
        self.data = data
        self.msg = msg
    }
}

// MARK: - 用户实体类
public struct Users: Codable {
    public let avatarUrl: String?
    public let birthDate: String?
    public let createTime: String?
    public let email: String?
    public let gender: Int?
    public let id: Int?
    public let location: String?
    public let nickname: String?
    public let password: String?
    public let phone: String?
    public let signature: String?
    public let status: Int?
    public let updateTime: String?
    public let username: String?
    
    public init(avatarUrl: String? = nil, birthDate: String? = nil, createTime: String? = nil, email: String? = nil, gender: Int? = nil, id: Int? = nil, location: String? = nil, nickname: String? = nil, password: String? = nil, phone: String? = nil, signature: String? = nil, status: Int? = nil, updateTime: String? = nil, username: String? = nil) {
        self.avatarUrl = avatarUrl
        self.birthDate = birthDate
        self.createTime = createTime
        self.email = email
        self.gender = gender
        self.id = id
        self.location = location
        self.nickname = nickname
        self.password = password
        self.phone = phone
        self.signature = signature
        self.status = status
        self.updateTime = updateTime
        self.username = username
    }
}

// MARK: - 用户注册协议
public class SoulUserRegisterProtocol: SoulBaseNetworkProtocol {
    public var username: String = ""
    public var password: String = ""
    public var nickname: String = ""
    
    public override init() {
        super.init()
    }
    
    public override func getAPIUrl() -> String {
        return "http://47.94.84.165:8080/community/user/register"
    }
    
    public override func getHttpBody() -> Data? {
        let user = Users(nickname: nickname, password: password, username: username)
        do {
            let jsonData = try JSONEncoder().encode(user)
            return jsonData
        } catch {
            print("编码用户数据失败: \(error)")
            return nil
        }
    }
    
    public override func getParameters() -> [String: Any] {
        // 由于使用JSON body，这里返回空字典
        return [:]
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
