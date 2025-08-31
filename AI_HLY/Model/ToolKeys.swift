//
//  ToolKeys.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 14/4/25.
//
//

import Foundation
import SwiftData


@Model
class ToolKeys {
    var name: String = ""
    var company: String = ""
    var key: String = ""            // 默认空字符串
    var requestURL: String = ""
    var price: Double? = 0.0        // 默认 0.0
    var isUsing: Bool = false       // 默认 false
    var toolClass: String = "tool"  // 默认为 tool
    var help: String = ""
    var timestamp: Date = Date()

    public init(
        name: String = "",
        company: String = "",
        key: String = "",
        requestURL: String = "",
        price: Double? = 0.0,
        isUsing: Bool = false,
        toolClass: String = "tool",
        help: String = "",
        timestamp: Date = Date()
    ) {
        self.name = name
        self.company = company
        self.key = key
        self.requestURL = requestURL
        self.price = price
        self.isUsing = isUsing
        self.toolClass = toolClass
        self.help = help
        self.timestamp = timestamp
    }
}
