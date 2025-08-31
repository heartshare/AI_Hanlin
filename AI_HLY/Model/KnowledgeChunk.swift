//
//  KnowledgeChunk.swift
//  AI_Hanlin
//
//  Created by 哆啦好多梦 on 28/3/25.
//
import Foundation
import SwiftData

@Model
class KnowledgeChunk {
    var id: UUID = UUID()
    var text: String?   // 这个切片的具体文本内容
    var vectorData: Data?  // 向量表示
    @Relationship(inverse: \KnowledgeRecords.chunks)
    var knowledgeRecord: KnowledgeRecords?  // 用于标识所属的 KnowledgeRecords

    init(text: String, vector: [Float], knowledgeRecord: KnowledgeRecords) {
        self.text = text
        self.vectorData = vectorToData(vector: vector)
        self.knowledgeRecord = knowledgeRecord
    }

    func getVector() -> [Float]? {
        guard let data = vectorData else { return nil }
        return dataToVector(data: data)
    }
}

func vectorToData(vector: [Float]) -> Data {
    return vector.withUnsafeBufferPointer { Data(buffer: $0) }
}

func dataToVector(data: Data) -> [Float] {
    let count = data.count / MemoryLayout<Float>.size
    return data.withUnsafeBytes {
        Array(UnsafeBufferPointer<Float>(start: $0.baseAddress!.assumingMemoryBound(to: Float.self), count: count))
    }
}

