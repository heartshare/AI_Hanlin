//
//  SearchKeys.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 9/2/25.
//
//

import Foundation
import SwiftData


@Model
class SearchKeys {
    var name: String? = nil
    var company: String? = nil
    var key: String? = ""           // 默认空字符串
    var requestURL: String? = nil
    var price: Double? = 0.0        // 默认 0.0
    var isUsing: Bool = false       // 默认 false
    var help: String = ""
    var timestamp: Date = Date()

    public init(
        name: String? = nil,
        company: String? = nil,
        key: String? = "",
        requestURL: String? = nil,
        price: Double? = 0.0,
        isUsing: Bool = false,
        help: String = "",
        timestamp: Date = Date()
    ) {
        self.name = name
        self.company = company
        self.key = key
        self.requestURL = requestURL
        self.price = price
        self.isUsing = isUsing
        self.help = help
        self.timestamp = timestamp
    }
}
