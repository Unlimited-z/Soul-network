//
//  DoubaoAIService.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import Foundation

public struct ChatMessage {
    public let id: String
    public let content: String
    public let isFromUser: Bool
    public let timestamp: Date
    
    public init(id: String, content: String, isFromUser: Bool, timestamp: Date) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}

// MARK: - API Models
public struct DoubaoAPIRequest: Codable {
    let model: String
    let messages: [DoubaoMessage]
    let temperature: Double?
    let maxTokens: Int?
    let topP: Double?
    let stream: Bool?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature, stream
        case maxTokens = "max_tokens"
        case topP = "top_p"
    }
}

public struct DoubaoMessage: Codable {
    let role: String
    let content: [DoubaoContent]
}

public struct DoubaoContent: Codable {
    let type: String
    let text: String?
    let imageUrl: DoubaoImageUrl?
    
    enum CodingKeys: String, CodingKey {
        case type, text
        case imageUrl = "image_url"
    }
}

public struct DoubaoImageUrl: Codable {
    let url: String
    let detail: String?
}

public struct DoubaoAPIResponse: Codable {
    let choices: [DoubaoChoice]
    let usage: DoubaoUsage?
}

public struct DoubaoChoice: Codable {
    let message: DoubaoResponseMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

public struct DoubaoResponseMessage: Codable {
    let role: String
    let content: String
}

public struct DoubaoUsage: Codable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

public struct DoubaoAPIError: Codable {
    let error: DoubaoErrorDetail
}

public struct DoubaoErrorDetail: Codable {
    let message: String
    let type: String?
    let code: String?
}

// MARK: - AI Service
public class DoubaoAIService {
    public static let shared = DoubaoAIService()
    
    private let baseURL = "https://ark.cn-beijing.volces.com/api/v3/chat/completions"
    private let apiKey = "beb28cc0-453d-489e-857a-028e0f00d0d8"
    private let model = "doubao-seed-1-6-250615"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Public Methods
    public func sendMessage(_ userMessage: String, 
                    imageURL: String? = nil,
                    systemMessage: String? = nil,
                    conversationHistory: [ChatMessage] = [],
                    completion: @escaping (Result<String, DoubaoAIServiceError>) -> Void) {
        
        // 构建消息历史
        var messages: [DoubaoMessage] = []
        
        // 如果有系统消息，首先添加系统消息
        if let systemMessage = systemMessage {
            let systemDoubaoMessage = DoubaoMessage(
                role: "system",
                content: [DoubaoContent(
                    type: "text",
                    text: systemMessage,
                    imageUrl: nil
                )]
            )
            messages.append(systemDoubaoMessage)
        }
        
        // 添加对话历史
        messages.append(contentsOf: conversationHistoryToDoubaoMessages(conversationHistory))
        
        // 创建用户消息内容
        var contentArray: [DoubaoContent] = []
        
        // 添加文本内容
        contentArray.append(DoubaoContent(
            type: "text",
            text: userMessage,
            imageUrl: nil
        ))
        
        // 如果有图片，添加图片内容
        if let imageURL = imageURL {
            contentArray.append(DoubaoContent(
                type: "image_url",
                text: nil,
                imageUrl: DoubaoImageUrl(url: imageURL, detail: nil)
            ))
        }
        
        let userDoubaoMessage = DoubaoMessage(
            role: "user",
            content: contentArray
        )
        
        messages.append(userDoubaoMessage)
        
        let request = DoubaoAPIRequest(
            model: model,
            messages: messages,
            temperature: 0.7,
            maxTokens: 2000,
            topP: 0.9,
            stream: false
        )
        
        performRequest(request: request, completion: completion)
    }
    
    // 新增方法：AI 发起对话
    public func initiateConversation(systemMessage: String? = nil,
                             completion: @escaping (Result<String, DoubaoAIServiceError>) -> Void) {
        
        var messages: [DoubaoMessage] = []
        
        // 如果有系统消息，首先添加系统消息
        if let systemMessage = systemMessage {
            let systemDoubaoMessage = DoubaoMessage(
                role: "system",
                content: [DoubaoContent(
                    type: "text",
                    text: systemMessage,
                    imageUrl: nil
                )]
            )
            messages.append(systemDoubaoMessage)
        }
        
        // 添加一个空的用户消息来触发 AI 回应
        let triggerMessage = DoubaoMessage(
            role: "user",
            content: [DoubaoContent(
                type: "text",
                text: "请开始我们的对话。",
                imageUrl: nil
            )]
        )
        
        messages.append(triggerMessage)
        
        let request = DoubaoAPIRequest(
            model: model,
            messages: messages,
            temperature: 0.7,
            maxTokens: 2000,
            topP: 0.9,
            stream: false
        )
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Private Methods
    private func conversationHistoryToDoubaoMessages(_ history: [ChatMessage]) -> [DoubaoMessage] {
        return history.compactMap { chatMessage in
            // 只处理非加载消息
            guard chatMessage.id != "loading" else { return nil }
            
            let content = [DoubaoContent(
                type: "text",
                text: chatMessage.content,
                imageUrl: nil
            )]
            
            return DoubaoMessage(
                role: chatMessage.isFromUser ? "user" : "assistant",
                content: content
            )
        }
    }
    
    private func performRequest(request: DoubaoAPIRequest, 
                              completion: @escaping (Result<String, DoubaoAIServiceError>) -> Void) {
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            // 打印请求信息用于调试
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("🚀 豆包 API 请求: \(jsonString)")
            }
            
            let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.handleResponse(data: data, response: response, error: error, completion: completion)
                }
            }
            
            task.resume()
            
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }
    
    private func handleResponse(data: Data?, 
                              response: URLResponse?, 
                              error: Error?, 
                              completion: @escaping (Result<String, DoubaoAIServiceError>) -> Void) {
        
        // 检查网络错误
        if let error = error {
            completion(.failure(.networkError(error)))
            return
        }
        
        // 检查 HTTP 状态码
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(.invalidResponse))
            return
        }
        
        // 打印响应信息用于调试
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("📨 豆包 API 响应: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let data = data,
               let errorResponse = try? JSONDecoder().decode(DoubaoAPIError.self, from: data) {
                completion(.failure(.apiError(errorResponse.error.message)))
            } else {
                completion(.failure(.httpError(httpResponse.statusCode)))
            }
            return
        }
        
        // 解析响应数据
        guard let data = data else {
            completion(.failure(.noData))
            return
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(DoubaoAPIResponse.self, from: data)
            
            if let firstChoice = apiResponse.choices.first {
                let aiResponse = firstChoice.message.content
                completion(.success(aiResponse))
            } else {
                completion(.failure(.noResponse))
            }
            
        } catch {
            print("❌ 解析错误: \(error)")
            completion(.failure(.decodingError(error)))
        }
    }
}

// MARK: - Doubao AI Service Error Types
public enum DoubaoAIServiceError: Error, LocalizedError {
    case invalidURL
    case encodingError(Error)
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case noData
    case decodingError(Error)
    case noResponse
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .encodingError(let error):
            return "编码错误: \(error.localizedDescription)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let statusCode):
            return "HTTP 错误 (\(statusCode))"
        case .apiError(let message):
            return "API 错误: \(message)"
        case .noData:
            return "没有接收到数据"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        case .noResponse:
            return "AI 没有返回响应"
        }
    }
}
