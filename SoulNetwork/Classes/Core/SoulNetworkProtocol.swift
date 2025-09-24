//
//  SoulNetworkProtocol.swift
//  SoulNetwork
//
//  Created by Ricard.li on 2025/1/24.
//

import Foundation
import UIKit

// MARK: - 网络错误定义
public enum SoulNetworkError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case noDataError
    case parseError(Error)
    case httpError(Int)
    case apiError(String, Int?)
    case encodingError(Error)
    case decodingError(Error)
    case invalidResponse
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .noDataError:
            return "没有接收到数据"
        case .parseError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP 错误 (\(statusCode))"
        case .apiError(let message, let code):
            if let code = code {
                return "API 错误 (\(code)): \(message)"
            } else {
                return "API 错误: \(message)"
            }
        case .encodingError(let error):
            return "编码错误: \(error.localizedDescription)"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        case .invalidResponse:
            return "无效的响应"
        case .timeout:
            return "请求超时"
        }
    }
}

// MARK: - 网络协议定义
public protocol SoulNetworkProtocol {
    // 基本请求信息
    func getAPIUrl() -> String
    func getParameters() -> [String: Any]
    func getHeaders() -> [String: String]?
    func getHttpBody() -> Data?
    func getTimeoutInterval() -> TimeInterval
    func getHttpMethod() -> String
    
    // 回调闭包
    var successBlock: ((Any) -> Void)? { get set }
    var failureBlock: ((SoulNetworkError) -> Void)? { get set }
    
    // 启动网络请求
    func startRequest(success: @escaping (Any) -> Void, failure: @escaping (SoulNetworkError) -> Void)
}

// MARK: - 基础网络协议实现
open class SoulBaseNetworkProtocol: SoulNetworkProtocol {
    public var successBlock: ((Any) -> Void)?
    public var failureBlock: ((SoulNetworkError) -> Void)?
    
    public init() {}
    
    // 默认实现
    open func getAPIUrl() -> String { return "" }
    open func getParameters() -> [String: Any] { return [:] }
    open func getHeaders() -> [String: String]? { return nil }
    open func getHttpBody() -> Data? { return nil }
    open func getTimeoutInterval() -> TimeInterval { return 30.0 }
    open func getHttpMethod() -> String { return "POST" }
    
    public func startRequest(success: @escaping (Any) -> Void, failure: @escaping (SoulNetworkError) -> Void) {
        self.successBlock = success
        self.failureBlock = failure
        
        // 提交给网络管理器
        SoulNetworkManager.shared.addNetworkTask(self)
    }
}

// MARK: - 网络管理器
public class SoulNetworkManager {
    public static let shared = SoulNetworkManager()
    private let session = URLSession.shared
    
    private init() {}
    
    public func addNetworkTask(_ task: SoulNetworkProtocol) {
        guard let url = URL(string: task.getAPIUrl()) else {
            task.failureBlock?(.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = task.getHttpMethod()
        request.timeoutInterval = task.getTimeoutInterval()
        
        // 设置默认头部
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 设置自定义头部
        if let headers = task.getHeaders() {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // 设置请求体
        if let body = task.getHttpBody() {
            request.httpBody = body
        } else if task.getHttpMethod().uppercased() == "POST" || task.getHttpMethod().uppercased() == "PUT" {
            // 将参数转换为JSON
            let parameters = task.getParameters()
            if !parameters.isEmpty {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                    request.httpBody = jsonData
                } catch {
                    task.failureBlock?(.encodingError(error))
                    return
                }
            }
        } else if task.getHttpMethod().uppercased() == "GET" {
            // GET请求将参数添加到URL
            let parameters = task.getParameters()
            if !parameters.isEmpty {
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                if let newURL = urlComponents?.url {
                    request.url = newURL
                }
            }
        }
        
        // 打印请求信息用于调试
        print("🚀 网络请求: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "Unknown URL")")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📤 请求体: \(bodyString)")
        }
        
        // 发起网络请求
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.handleResponse(data: data, response: response, error: error, task: task)
            }
        }.resume()
    }
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?, task: SoulNetworkProtocol) {
        // 检查网络错误
        if let error = error {
            let networkError = SoulNetworkError.networkError(error)
            task.failureBlock?(networkError)
            return
        }
        
        // 检查HTTP响应
        guard let httpResponse = response as? HTTPURLResponse else {
            task.failureBlock?(.invalidResponse)
            return
        }
        
        // 打印响应信息用于调试
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("📨 网络响应 (\(httpResponse.statusCode)): \(responseString)")
        }
        
        // 检查HTTP状态码
        guard (200...299).contains(httpResponse.statusCode) else {
            // 尝试解析错误信息
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["message"] as? String {
                        let code = json["code"] as? Int
                        task.failureBlock?(.apiError(message, code))
                    } else {
                        task.failureBlock?(.httpError(httpResponse.statusCode))
                    }
                } catch {
                    task.failureBlock?(.httpError(httpResponse.statusCode))
                }
            } else {
                task.failureBlock?(.httpError(httpResponse.statusCode))
            }
            return
        }
        
        // 检查数据
        guard let data = data else {
            task.failureBlock?(.noDataError)
            return
        }
        
        // 尝试解析JSON
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            task.successBlock?(json)
        } catch {
            task.failureBlock?(.parseError(error))
        }
    }
}