//
//  AuthServiceManager.swift
//  SoulNetwork
//
//  Created by Ricard.li on 2025/1/24.
//

import Foundation
import UIKit

// MARK: - Notification Extensions
extension Notification.Name {
    public static let userDidLogin = Notification.Name("userDidLogin")
    public static let userDidLogout = Notification.Name("userDidLogout")
    public static let tokenDidExpire = Notification.Name("tokenDidExpire")
}

// MARK: - JWT Token 结构
public struct JWTPayload: Codable {
    let exp: TimeInterval  // 过期时间戳
    let iat: TimeInterval? // 签发时间戳
    let sub: String?       // 主题（通常是用户ID）
    let username: String?  // 用户名
}

// MARK: - 认证服务管理器
public class AuthServiceManager {
    public static let shared = AuthServiceManager()
    
    // MARK: - 用户状态管理
    private let usernameKey = "SoulUsername"
    
    /// 当前用户是否已登录（包含token有效性检查）
    public var isAuthenticated: Bool {
        guard let token = SoulNetworkManager.shared.getJWTToken() else {
            return false
        }
        return isTokenValid(token)
    }
    
    /// 当前登录的用户名
    public var currentUsername: String? {
        return UserDefaults.standard.string(forKey: usernameKey)
    }
    
    /// 获取JWT token
    public var jwtToken: String? {
        return SoulNetworkManager.shared.getJWTToken()
    }
    
    /// 获取Authorization头的值（包含Bearer前缀）
    public var authorizationHeader: String? {
        guard let token = jwtToken else { return nil }
        return "Bearer \(token)"
    }
    
    private init() {}
    
    // MARK: - JWT Token 校验方法
    
    /// 检查JWT token是否有效（未过期）
    public func isTokenValid(_ token: String) -> Bool {
        guard let payload = parseJWTPayload(from: token) else {
            return false
        }
        
        let currentTime = Date().timeIntervalSince1970
        return payload.exp > currentTime
    }
    
    /// 检查当前存储的token是否有效
    public func isCurrentTokenValid() -> Bool {
        guard let token = jwtToken else { return false }
        return isTokenValid(token)
    }
    
    /// 解析JWT token的payload部分
    private func parseJWTPayload(from token: String) -> JWTPayload? {
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else {
            print("❌ JWT token格式无效")
            return nil
        }
        
        let payloadSegment = segments[1]
        
        // JWT使用Base64URL编码，需要处理padding
        var base64String = payloadSegment
        let remainder = base64String.count % 4
        if remainder > 0 {
            base64String += String(repeating: "=", count: 4 - remainder)
        }
        
        // 将Base64URL转换为Base64
        base64String = base64String
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        guard let data = Data(base64Encoded: base64String) else {
            print("❌ JWT payload Base64解码失败")
            return nil
        }
        
        do {
            let payload = try JSONDecoder().decode(JWTPayload.self, from: data)
            return payload
        } catch {
            print("❌ JWT payload JSON解析失败: \(error)")
            return nil
        }
    }
    
    /// 获取token的剩余有效时间（秒）
    public func getTokenRemainingTime() -> TimeInterval? {
        guard let token = jwtToken,
              let payload = parseJWTPayload(from: token) else {
            return nil
        }
        
        let currentTime = Date().timeIntervalSince1970
        let remainingTime = payload.exp - currentTime
        return remainingTime > 0 ? remainingTime : 0
    }
    
    /// 检查token是否即将过期（默认30分钟内）
    public func isTokenExpiringSoon(within minutes: Int = 30) -> Bool {
        guard let remainingTime = getTokenRemainingTime() else {
            return true // 如果无法获取剩余时间，认为即将过期
        }
        
        let thresholdSeconds = TimeInterval(minutes * 60)
        return remainingTime <= thresholdSeconds
    }
    
    /// 处理token过期的情况
    public func handleTokenExpiry() {
        print("🔒 Token已过期，执行自动登出")
        
        // 清除本地存储的用户信息
        SoulNetworkManager.shared.setJWTToken(nil)
        UserDefaults.standard.removeObject(forKey: usernameKey)
        UserDefaults.standard.synchronize()
        
        // 发送token过期通知
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .tokenDidExpire, object: nil)
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
        }
    }
    
    /// 校验当前token，如果过期则自动处理
    public func validateCurrentToken() -> Bool {
        guard let token = jwtToken else {
            return false
        }
        
        if isTokenValid(token) {
            return true
        } else {
            handleTokenExpiry()
            return false
        }
    }
    
    // MARK: - 登录相关方法
    
    /// 用户登录
    public func login(username: String, 
                     password: String,
                     completion: @escaping (Result<LoginResponse, SoulNetworkError>) -> Void) {
        
        let loginProtocol = SoulUserLoginProtocol()
        loginProtocol.username = username
        loginProtocol.password = password
        
        loginProtocol.startRequest(
            success: { response in
                self.handleLoginResponse(response: response, username: username, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    // MARK: - 注册相关方法
    
    /// 用户注册
    public func register(username: String,
                         password: String,
                         nickname: String,
                         completion: @escaping (Result<RegisterResponse, SoulNetworkError>) -> Void) {
        
        let registerProtocol = SoulUserRegisterProtocol()
        registerProtocol.username = username
        registerProtocol.password = password
        registerProtocol.nickname = nickname
        
        registerProtocol.startRequest(
            success: { response in
                self.handleRegisterResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    // MARK: - 登出相关方法
    
    /// 用户登出
    public func signOut() throws {
        // 清除本地存储的用户信息
        SoulNetworkManager.shared.setJWTToken(nil)
        UserDefaults.standard.removeObject(forKey: usernameKey)
        UserDefaults.standard.synchronize()
        
        // 发送登出通知
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
        }
    }
    
    // MARK: - 私有方法
    
    private func handleLoginResponse(response: Any, username: String, completion: @escaping (Result<LoginResponse, SoulNetworkError>) -> Void) {
        guard let json = response as? [String: Any] else {
            completion(.failure(.parseError(NSError(domain: "AuthServiceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的响应格式"]))))
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
            
            // HTTP 200成功，保存用户信息
            // 保存JWT token到网络管理器（后端返回的data字段包含JWT token）
            SoulNetworkManager.shared.setJWTToken(loginResponse.data)
            
            // 保存用户名
            UserDefaults.standard.set(username, forKey: usernameKey)
            UserDefaults.standard.synchronize()
            
            // 发送登录成功通知
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .userDidLogin, object: nil)
            }
            
            completion(.success(loginResponse))
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
    
    private func handleRegisterResponse(response: Any, completion: @escaping (Result<RegisterResponse, SoulNetworkError>) -> Void) {
        guard let json = response as? [String: Any] else {
            completion(.failure(.parseError(NSError(domain: "AuthServiceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的响应格式"]))))
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: jsonData)
            completion(.success(registerResponse))
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
}