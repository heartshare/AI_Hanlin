//
//  ModelSync.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 12/2/25.
//

import Foundation

extension String {
    /// 将汉字转换为拼音（无音调），并去除空格
    func toPinyin() -> String {
        let mutableString = NSMutableString(string: self) as CFMutableString
        // 转换为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        // 去除音调
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        // 去除空格并返回
        return (mutableString as String).replacingOccurrences(of: " ", with: "")
    }
}
