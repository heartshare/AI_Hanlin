//
//  KnowledgeAPI.swift
//  AI_Hanlin
//
//  Created by 哆啦好多梦 on 29/3/25.
//

import Foundation

// MARK: - 嵌入生成函数
func generateEmbeddings(
    for texts: [String],
    modelName: String,
    apiKey: String,
    apiURL: String
) async throws -> [[Float]] {
    guard let url = URL(string: apiURL) else {
        throw URLError(.badURL)
    }
    
    var finalName = modelName
    
    if finalName == "Hanlin-BAAI/bge-m3" {
        finalName = "BAAI/bge-m3"
    }
    
    var requestBody: [String: Any] = [
        "model": finalName,
        "input": texts,
        "encoding_format": "float"
    ]

    if finalName != "BAAI/bge-m3" {
        requestBody["dimensions"] = 1024
    }
    
    let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        let code = (response as? HTTPURLResponse)?.statusCode ?? -999
        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
        throw NSError(domain: "EmbeddingAPI",
                      code: code,
                      userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    // 使用 JSONSerialization 解析响应 JSON，支持更多响应结构
    guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
          let dataArray = jsonObject["data"] as? [[String: Any]] else {
        throw NSError(domain: "ResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的响应格式或未能解析 embedding 数据"])
    }
    
    // 针对每个返回项，先将 embedding 强转为 [Double] 再转换为 [Float]
    let embeddings: [[Float]] = try dataArray.map { dict in
        guard let doubleEmbedding = dict["embedding"] as? [Double] else {
            throw NSError(domain: "ResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的响应格式或未能解析 embedding 数据"])
        }
        return doubleEmbedding.map { Float($0) }
    }
    
    guard embeddings.count == texts.count else {
        throw NSError(domain: "EmbeddingAPI", code: -3, userInfo: [NSLocalizedDescriptionKey: "返回的 embedding 数量与输入文本数量不一致"])
    }
    
    return embeddings
}
