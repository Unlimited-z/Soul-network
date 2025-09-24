//
//  DoubaoImageService.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import Foundation

// MARK: - Image Generation API Models
public struct DoubaoImageRequest: Codable {
    let model: String
    let prompt: String
    let responseFormat: String
    let size: String
    let seed: Int?
    let guidanceScale: Double?
    let watermark: Bool?
    
    enum CodingKeys: String, CodingKey {
        case model, prompt, size, seed, watermark
        case responseFormat = "response_format"
        case guidanceScale = "guidance_scale"
    }
}

public struct DoubaoImageResponse: Codable {
    let model: String
    let created: Int
    let data: [DoubaoImageData]
    let usage: DoubaoImageUsage?
}

public struct DoubaoImageData: Codable {
    let url: String?
    let b64Json: String?
    let revisedPrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case b64Json = "b64_json"
        case revisedPrompt = "revised_prompt"
    }
}

public struct DoubaoImageUsage: Codable {
    let generatedImages: Int
    let outputTokens: Int?
    let totalTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case generatedImages = "generated_images"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
    }
}

public struct DoubaoImageError: Codable {
    let error: DoubaoImageErrorDetail
}

public struct DoubaoImageErrorDetail: Codable {
    let message: String
    let type: String?
    let code: String?
}

// MARK: - Image Generation Service
// MARK: - Image Service
public class DoubaoImageService {
    public static let shared = DoubaoImageService()
    
    private let baseURL = "https://ark.cn-beijing.volces.com/api/v3/images/generations"
    private let apiKey = "beb28cc0-453d-489e-857a-028e0f00d0d8"
    private let model = "doubao-seedream-3-0-t2i-250415"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Public Methods
    public func generateImage(prompt: String,
                      size: String = "720x1280",
                      seed: Int? = nil,
                      guidanceScale: Double = 2.5,
                      watermark: Bool = false,
                      completion: @escaping (Result<String, ImageServiceError>) -> Void) {
        
        let request = DoubaoImageRequest(
            model: model,
            prompt: prompt,
            responseFormat: "url",
            size: size,
            seed: seed,
            guidanceScale: guidanceScale,
            watermark: watermark
        )
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Private Methods
    private func performRequest(request: DoubaoImageRequest,
                              completion: @escaping (Result<String, ImageServiceError>) -> Void) {
        
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
                print("🎨 豆包图片生成请求: \(jsonString)")
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
                              completion: @escaping (Result<String, ImageServiceError>) -> Void) {
        
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
            print("🖼️ 豆包图片生成响应: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let data = data,
               let errorResponse = try? JSONDecoder().decode(DoubaoImageError.self, from: data) {
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
            let apiResponse = try JSONDecoder().decode(DoubaoImageResponse.self, from: data)
            
            // 打印使用统计信息
            if let usage = apiResponse.usage {
                print("📊 图片生成统计 - 生成图片数: \(usage.generatedImages), 输出tokens: \(usage.outputTokens ?? 0), 总tokens: \(usage.totalTokens ?? 0)")
            }
            
            if let firstImage = apiResponse.data.first,
               let imageURL = firstImage.url {
                print("✅ 图片生成成功，URL: \(imageURL)")
                completion(.success(imageURL))
            } else {
                completion(.failure(.noImageURL))
            }
            
        } catch {
            print("❌ 图片响应解析错误: \(error)")
            completion(.failure(.decodingError(error)))
        }
    }
}

// MARK: - Image Service Error Types
public enum ImageServiceError: Error, LocalizedError {
    case invalidURL
    case encodingError(Error)
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case noData
    case decodingError(Error)
    case noImageURL
    
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
        case .noImageURL:
            return "没有返回图片 URL"
        }
    }
}
