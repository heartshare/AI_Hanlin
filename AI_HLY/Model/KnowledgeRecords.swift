//
//  KnowledgeRecords.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 28/3/25.
//
//

import Foundation
import SwiftData

@Model
class KnowledgeRecords {
    var id: UUID = UUID()
    @Attribute(.spotlight)
    var name: String = "新知识"
    var lastEdited: Date = Date()
    var isPinned: Bool = false
    var icon: String? // 图标
    var color: String? // 颜色
    var content: String? // 内容
    var isEmbedding: Bool = false // 是否已经向量化
    @Relationship(deleteRule: .cascade)
    var chunks: [KnowledgeChunk]?
    
    // 初始化方法
    public init(
        id: UUID = UUID(),
        name: String = "新知识",
        lastEdited: Date = Date(),
        isPinned: Bool = false,
        icon: String = "document.circle",
        color: String = "hlBlue",
        content: String = "",
        isEmbedding: Bool = false,
        chunks: [KnowledgeChunk]? = nil
    ) {
        self.id = id
        self.name = name
        self.lastEdited = lastEdited
        self.isPinned = isPinned
        self.icon = icon
        self.color = color
        self.content = content
        self.isEmbedding = isEmbedding
        self.chunks = chunks
    }
}


