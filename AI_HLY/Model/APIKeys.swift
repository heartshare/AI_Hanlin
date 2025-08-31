//
//  APIKeys.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 9/2/25.
//
//

import Foundation
import SwiftData

@Model
class APIKeys {
    var name: String? = ""
    var company: String? = ""
    var key: String? = ""          // 默认空字符串
    var requestURL: String? = nil
    var isHidden: Bool = true      // 默认 true
    var help: String = ""
    var timestamp: Date = Date()

    public init(
        name: String? = "",
        company: String? = "",
        key: String? = "",
        requestURL: String? = nil,
        isHidden: Bool = true,
        help: String = "",
        timestamp: Date = Date()
    ) {
        self.name = name
        self.company = company
        self.key = key
        self.requestURL = requestURL
        self.isHidden = isHidden
        self.help = help
        self.timestamp = timestamp
    }
}
