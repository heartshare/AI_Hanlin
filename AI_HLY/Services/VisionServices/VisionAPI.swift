//
//  Services/APIManager.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 4/2/25.
//

import Foundation
import PhotosUI
import SwiftData


class ImageAPIManager{
    
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func getAPIKey(for company: String, context: ModelContext) -> String? {
        let predicate = #Predicate<APIKeys> { $0.company == company }
        let fetchDescriptorFiltered = FetchDescriptor<APIKeys>(predicate: predicate)
        if let result = try? context.fetch(fetchDescriptorFiltered).first {
            return result.key
        }
        return nil
    }
    
    func getRequestURL(for company: String, context: ModelContext) -> String? {
        let predicate = #Predicate<APIKeys> { $0.company == company }
        let fetchDescriptor = FetchDescriptor<APIKeys>(predicate: predicate)
        if let result = try? context.fetch(fetchDescriptor).first {
            return result.requestURL
        }
        return nil
    }
    
    private var currentTask: URLSessionDataTask? // 记录当前的流式请求任务
    private var isCancelled = false // 标记请求是否被取消
    
    // 终止当前的流式请求
    func cancelCurrentRequest() {
        isCancelled = true
        currentTask?.cancel()
        currentTask = nil
    }
    
    // 流式请求方法
    func sendPhotoStreamRequest(
        message: [(role: String, image: UIImage?, text: String?)],
        modelDisplayName: String
    ) async throws -> AsyncThrowingStream<String, Swift.Error> {
        // 取消当前请求
        if let currentTask = currentTask {
            currentTask.cancel()
            self.currentTask = nil
        }
        
        isCancelled = false
        
        let currentLanguage = Locale.preferredLanguages.first ?? "zh-Hans"
        
        guard let modelInfo = try? context.fetch(
            FetchDescriptor<AllModels>(
                predicate: #Predicate { $0.displayName == modelDisplayName }
            )
        ).first else {
            throw NSError(domain: "DatabaseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法获取模型信息"])
        }
        
        guard let apiKey = getAPIKey(for: modelInfo.company ?? "Unknown", context: context) else {
            throw NSError(domain: "APIConfigError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的 API Key"])
        }
        
        guard let requestURLString = getRequestURL(for: modelInfo.company ?? "Unknown", context: context),
              let requestURL = URL(string: requestURLString), !requestURLString.isEmpty else {
            throw NSError(domain: "URLConfigError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的请求 URL"])
        }
        
        var formattedMessages: [[String: Any]] = []
        
        if modelInfo.identity == "agent" {
            
            let systemRole: String = {
                switch modelInfo.company {
                case "OPENAI": return "developer"
                default: return "system"
                }
            }()
            
            var agentInfo = ""
            if currentLanguage.hasPrefix("zh") {
                agentInfo = "# 你是【\(modelDisplayName)】。\n#你被设定为：\n\(modelInfo.characterDesign ?? "\(modelDisplayName)")\n请记住你的设定，在回复时保证始终遵循这个设定!"
            } else {
                agentInfo = "# You are [\(modelDisplayName)].\n# You have been configured as:\n\(modelInfo.characterDesign ?? "\(modelDisplayName)")\nPlease remember your configuration and always adhere to it when replying!"
            }
            formattedMessages.append([
                "role": systemRole,
                "content": agentInfo
            ])
        }
        
        let userMessage: String
        if currentLanguage.hasPrefix("zh") {
            userMessage = "解析图片的视觉语义，识别核心需求（例如：场景识别/内容翻译/对象辨认/情感支持/问题解答）并选择置信度最高的一个视角，不要展示选择的过程和理由，直接给出最终的针对该需求的图片分析内容。"
        } else {
            userMessage = "Analyze the visual semantics of the image, identify core needs (e.g., scene recognition/content translation/object identification/emotional support/question answering), and select the perspective with the highest confidence. Do not show the selection process or reasoning; directly provide the final image analysis content addressing that need."
        }

        formattedMessages.append([
            "role": "user",
            "content": userMessage
        ])
        
        // 遍历用户和 AI 过往对话，保持上下文
        for msg in message {
            var messageData: [String: Any] = ["role": msg.role]
            var contentArray: [[String: Any]] = []
            
            // 处理文本
            if let text = msg.text {
                contentArray.append(["type": "text", "text": text])
            }
            
            // 处理图片
            if let image = msg.image {
                guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                    throw NSError(domain: "FileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析图片数据"])
                }
                let base64String = imageData.base64EncodedString()
                
                var imageUrlValue: [String: Any] = [:]
                switch modelInfo.company?.uppercased() {
                case "ZHIPUAI":
                    imageUrlValue["url"] = base64String
                case "HANLIN":
                    imageUrlValue["url"] = base64String
                case "XAI":
                    imageUrlValue["url"] = "data:image/jpeg;base64,\(base64String)"
                    imageUrlValue["detail"] = "high"
                default:
                    imageUrlValue["url"] = "data:image/jpeg;base64,\(base64String)"
                }
                
                contentArray.append(["type": "image_url", "image_url": imageUrlValue])
            }
            
            // 如果 `contentArray` 为空，则跳过
            if !contentArray.isEmpty {
                messageData["content"] = contentArray
                formattedMessages.append(messageData)
            }
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var requestBody: [String: Any]
        
        let baseName = restoreBaseModelName(from: modelInfo.name ?? "Unknown")
        
        requestBody = [
            "model": baseName,
            "messages": formattedMessages,
            "stream": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let (result, response) = try await URLSession.shared.bytes(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "HTTP 响应无效"])
        }
        
        guard 200...299 ~= response.statusCode else {
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "请求错误"])
        }
        
        return AsyncThrowingStream<String, Swift.Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    
                    for try await line in result.lines {
                        
                        if self.isCancelled {
                            continuation.finish()
                            self.isCancelled = false
                            break
                        }
                        
                        if line.hasPrefix("data: ") {
                            let jsonString = line.replacingOccurrences(of: "data: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                            guard let jsonData = jsonString.data(using: .utf8) else { return }
                            guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { return }
                            guard let choices = jsonObject["choices"] as? [[String: Any]] else { return }
                            guard let delta = choices.first?["delta"] as? [String: Any] else { return }
                            
                            if let photoAnalysisText = delta["content"] as? String {
                                continuation.yield(photoAnalysisText)
                            }
                            
                            if let finishReason = choices.first?["finish_reason"] as? String {
                                if finishReason == "stop" {
                                    break
                                } else if finishReason == "length" {
                                    break
                                } else if finishReason == "sensitive" {
                                    break
                                } else {
                                    break
                                }
                            }
                        }
                    }
                    continuation.finish()
                    self.isCancelled = false
                } catch {
                    continuation.finish(throwing: error)
                }
                continuation.onTermination = { @Sendable status in
                    continuation.finish()
                }
            }
        }
    }
}
