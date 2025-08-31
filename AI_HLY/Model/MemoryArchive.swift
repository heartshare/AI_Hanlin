//
//  MemoryArchive.swift
//  AI_Hanlin
//
//  Created by 哆啦好多梦 on 18/3/25.
//

import Foundation
import SwiftData

@Model
class MemoryArchive {
    var id: UUID = UUID()
    var content: String? = nil
    var timestamp: Date = Date()

    public init(
        id: UUID = UUID(),
        content: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}
