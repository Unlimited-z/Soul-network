//
//  AuthServiceManager.swift
//  SoulNetwork
//
//  Created by Ricard.li on 2025/1/24.
//

import Foundation
import UIKit

// MARK: - 认证服务管理器
public class AuthServiceManager {
    public static let shared = AuthServiceManager()
    
    private init() {}
    
    // MARK: - 登录相关方法
    
    /// 手机号密码登录
    public func loginWithPhonePassword(phone: String, 
                               password: String, 
                               areaCode: String = "86",
                               completion: @escaping (Result<LoginData, SoulNetworkError>) -> Void) {
        
        let loginProtocol = SoulPhonePasswordLoginProtocol()
        loginProtocol.phone = phone
        loginProtocol.password = password
        loginProtocol.areaCode = areaCode
        
        loginProtocol.startRequest(
            success: { response in
                self.handleLoginResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 手机号验证码登录
    public func loginWithPhoneCode(phone: String,
                           verificationCode: String,
                           codeId: String,
                           areaCode: String = "86",
                           completion: @escaping (Result<LoginData, SoulNetworkError>) -> Void) {
        
        let loginProtocol = SoulPhoneCodeLoginProtocol()
        loginProtocol.phone = phone
        loginProtocol.verificationCode = verificationCode
        loginProtocol.codeId = codeId
        loginProtocol.areaCode = areaCode
        
        loginProtocol.startRequest(
            success: { response in
                self.handleLoginResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 邮箱登录
    public func loginWithEmail(email: String,
                       password: String,
                       completion: @escaping (Result<LoginData, SoulNetworkError>) -> Void) {
        
        let loginProtocol = SoulEmailLoginProtocol()
        loginProtocol.email = email
        loginProtocol.password = password
        
        loginProtocol.startRequest(
            success: { response in
                self.handleLoginResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 第三方登录
    public func loginWithThirdParty(platform: String,
                            accessToken: String,
                            openId: String,
                            unionId: String? = nil,
                            userInfo: [String: Any]? = nil,
                            completion: @escaping (Result<LoginData, SoulNetworkError>) -> Void) {
        
        let loginProtocol = SoulThirdPartyLoginProtocol()
        loginProtocol.platform = platform
        loginProtocol.accessToken = accessToken
        loginProtocol.openId = openId
        loginProtocol.unionId = unionId
        loginProtocol.userInfo = userInfo
        
        loginProtocol.startRequest(
            success: { response in
                self.handleLoginResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 发送登录验证码
    public func sendLoginCode(phone: String,
                      areaCode: String = "86",
                      completion: @escaping (Result<VerificationCodeData, SoulNetworkError>) -> Void) {
        
        let codeProtocol = SoulSendLoginCodeProtocol()
        codeProtocol.phone = phone
        codeProtocol.areaCode = areaCode
        codeProtocol.codeType = "login"
        
        codeProtocol.startRequest(
            success: { response in
                self.handleCodeResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    // MARK: - 注册相关方法
    
    /// 手机号注册
    public func registerWithPhone(phone: String,
                          password: String,
                          verificationCode: String,
                          codeId: String,
                          areaCode: String = "86",
                          nickname: String? = nil,
                          inviteCode: String? = nil,
                          completion: @escaping (Result<RegisterData, SoulNetworkError>) -> Void) {
        
        let registerProtocol = SoulPhoneRegisterProtocol()
        registerProtocol.phone = phone
        registerProtocol.password = password
        registerProtocol.verificationCode = verificationCode
        registerProtocol.codeId = codeId
        registerProtocol.areaCode = areaCode
        registerProtocol.nickname = nickname
        registerProtocol.inviteCode = inviteCode
        
        registerProtocol.startRequest(
            success: { response in
                self.handleRegisterResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 邮箱注册
    public func registerWithEmail(email: String,
                          password: String,
                          verificationCode: String,
                          codeId: String,
                          nickname: String? = nil,
                          inviteCode: String? = nil,
                          completion: @escaping (Result<RegisterData, SoulNetworkError>) -> Void) {
        
        let registerProtocol = SoulEmailRegisterProtocol()
        registerProtocol.email = email
        registerProtocol.password = password
        registerProtocol.verificationCode = verificationCode
        registerProtocol.codeId = codeId
        registerProtocol.nickname = nickname
        registerProtocol.inviteCode = inviteCode
        
        registerProtocol.startRequest(
            success: { response in
                self.handleRegisterResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 发送注册验证码
    public func sendRegisterCode(phone: String? = nil,
                         email: String? = nil,
                         areaCode: String = "86",
                         completion: @escaping (Result<VerificationCodeData, SoulNetworkError>) -> Void) {
        
        let codeProtocol = SoulSendRegisterCodeProtocol()
        codeProtocol.phone = phone
        codeProtocol.email = email
        codeProtocol.areaCode = areaCode
        
        codeProtocol.startRequest(
            success: { response in
                self.handleCodeResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    // MARK: - 可用性检查方法
    
    /// 检查手机号是否可用
    public func checkPhoneAvailability(phone: String,
                               areaCode: String = "86",
                               completion: @escaping (Result<CheckAvailabilityData, SoulNetworkError>) -> Void) {
        
        let checkProtocol = SoulCheckPhoneAvailabilityProtocol()
        checkProtocol.phone = phone
        checkProtocol.areaCode = areaCode
        
        checkProtocol.startRequest(
            success: { response in
                self.handleAvailabilityResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 检查邮箱是否可用
    public func checkEmailAvailability(email: String,
                               completion: @escaping (Result<CheckAvailabilityData, SoulNetworkError>) -> Void) {
        
        let checkProtocol = SoulCheckEmailAvailabilityProtocol()
        checkProtocol.email = email
        
        checkProtocol.startRequest(
            success: { response in
                self.handleAvailabilityResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 检查昵称是否可用
    public func checkNicknameAvailability(nickname: String,
                                  completion: @escaping (Result<CheckAvailabilityData, SoulNetworkError>) -> Void) {
        
        let checkProtocol = SoulCheckNicknameAvailabilityProtocol()
        checkProtocol.nickname = nickname
        
        checkProtocol.startRequest(
            success: { response in
                self.handleAvailabilityResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    // MARK: - Token 相关方法
    
    /// 刷新Token
    public func refreshToken(refreshToken: String,
                     completion: @escaping (Result<LoginData, SoulNetworkError>) -> Void) {
        
        let refreshProtocol = SoulRefreshTokenProtocol()
        refreshProtocol.refreshToken = refreshToken
        
        refreshProtocol.startRequest(
            success: { response in
                self.handleLoginResponse(response: response, completion: completion)
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    /// 登出
    public func logout(token: String,
               completion: @escaping (Result<Void, SoulNetworkError>) -> Void) {
        
        let logoutProtocol = SoulLogoutProtocol()
        logoutProtocol.token = token
        
        logoutProtocol.startRequest(
            success: { _ in
                completion(.success(()))
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    // MARK: - 密码重置方法
    
    /// 重置密码
    public func resetPassword(phone: String? = nil,
                      email: String? = nil,
                      verificationCode: String,
                      codeId: String,
                      newPassword: String,
                      areaCode: String = "86",
                      completion: @escaping (Result<Void, SoulNetworkError>) -> Void) {
        
        let resetProtocol = SoulResetPasswordProtocol()
        resetProtocol.phone = phone
        resetProtocol.email = email
        resetProtocol.verificationCode = verificationCode
        resetProtocol.codeId = codeId
        resetProtocol.newPassword = newPassword
        resetProtocol.areaCode = areaCode
        
        resetProtocol.startRequest(
            success: { _ in
                completion(.success(()))
            },
            failure: { error in
                completion(.failure(error))
            }
        )
    }
    
    // MARK: - 私有方法
    
    private func handleLoginResponse(response: Any, completion: @escaping (Result<LoginData, SoulNetworkError>) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response)
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
            
            if loginResponse.success, let data = loginResponse.data {
                completion(.success(data))
            } else {
                let message = loginResponse.message ?? "登录失败"
                completion(.failure(.apiError(message, loginResponse.code)))
            }
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
    
    private func handleRegisterResponse(response: Any, completion: @escaping (Result<RegisterData, SoulNetworkError>) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response)
            let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: jsonData)
            
            if registerResponse.success, let data = registerResponse.data {
                completion(.success(data))
            } else {
                let message = registerResponse.message ?? "注册失败"
                completion(.failure(.apiError(message, registerResponse.code)))
            }
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
    
    private func handleCodeResponse(response: Any, completion: @escaping (Result<VerificationCodeData, SoulNetworkError>) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response)
            let codeResponse = try JSONDecoder().decode(VerificationCodeResponse.self, from: jsonData)
            
            if codeResponse.success, let data = codeResponse.data {
                completion(.success(data))
            } else {
                let message = codeResponse.message ?? "发送验证码失败"
                completion(.failure(.apiError(message, codeResponse.code)))
            }
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
    
    private func handleAvailabilityResponse(response: Any, completion: @escaping (Result<CheckAvailabilityData, SoulNetworkError>) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response)
            let availabilityResponse = try JSONDecoder().decode(CheckAvailabilityResponse.self, from: jsonData)
            
            if availabilityResponse.success, let data = availabilityResponse.data {
                completion(.success(data))
            } else {
                let message = availabilityResponse.message ?? "检查可用性失败"
                completion(.failure(.apiError(message, availabilityResponse.code)))
            }
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
}