//
//  APIBalance.swift
//  AI_Hanlin
//
//  Created by 哆啦好多梦 on 24/3/25.
//

import Foundation

func fetchDeepSeekBalance(token: String) async throws -> Double {
    guard let url = URL(string: "https://api.deepseek.com/user/balance") else {
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)

    let decoded = try JSONDecoder().decode(DeepSeekBalanceResponse.self, from: data)
    if let cny = decoded.balance_infos.first(where: { $0.currency == "CNY" }),
       let value = Double(cny.total_balance) {
        return value
    } else {
        throw NSError(domain: "NoCNYBalance", code: 0)
    }
}

private struct DeepSeekBalanceResponse: Codable {
    let is_available: Bool
    let balance_infos: [DeepSeekBalanceInfo]
}

private struct DeepSeekBalanceInfo: Codable {
    let currency: String
    let total_balance: String
    let granted_balance: String
    let topped_up_balance: String
}


func fetchSiliconFlowBalance(token: String) async throws -> Double {
    guard let url = URL(string: "https://api.siliconflow.cn/v1/user/info") else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    let decodedResponse = try JSONDecoder().decode(SiliconFlowUserInfoResponse.self, from: data)
    
    // 这里判断 code 是否为 20000 表示请求成功，并从 data 中提取 balance（注意返回的是字符串，需要转换为 Double）
    if decodedResponse.code == 20000, let balance = Double(decodedResponse.data.balance) {
        return balance
    } else {
        throw NSError(domain: "SiliconFlowAPI",
                      code: decodedResponse.code,
                      userInfo: [NSLocalizedDescriptionKey: "无法获取余额"])
    }
}

private struct SiliconFlowUserInfoResponse: Codable {
    let code: Int
    let message: String
    let status: Bool
    let data: SiliconFlowUserInfoData
}

private struct SiliconFlowUserInfoData: Codable {
    let id: String
    let name: String
    let image: String
    let email: String
    let isAdmin: Bool
    let balance: String
    let status: String
    let introduction: String
    let role: String
    let chargeBalance: String
    let totalBalance: String
}

