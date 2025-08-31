//
//  WebReadTool.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 14/3/25.
//

import Foundation
import SwiftSoup

func fetchWebPageContent(from urls: [String]) async -> [(url: String, title: String, content: String, icon: String)] {
    var webPageContents: [(url: String, title: String, content: String, icon: String)] = []

    for urlString in urls {
        guard let url = URL(string: urlString) else { continue }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Failed to fetch webpage: \(urlString)")
                continue
            }
            
            if let htmlString = String(data: data, encoding: .utf8) {
                let extractedTitle = extractTitle(from: htmlString)
                let extractedContent = extractMainContent(from: htmlString)
                let faviconURL = extractFavicon(from: htmlString, pageURL: url)

                if !extractedContent.isEmpty {
                    webPageContents.append((url: urlString, title: extractedTitle, content: extractedContent, icon: faviconURL))
                }
            }
        } catch {
            print("Error fetching webpage content for \(urlString): \(error.localizedDescription)")
        }
    }

    return webPageContents
}

// **提取网页标题**
func extractTitle(from html: String) -> String {
    do {
        let document = try SwiftSoup.parse(html)

        // **1 优先尝试 `<title>` 标签**
        if let titleElement = try? document.title(), !titleElement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanedTitle = titleElement.trimmingCharacters(in: .whitespacesAndNewlines)
            if isValidTitle(cleanedTitle) { return cleanedTitle }
        }
        
        // **2 其次尝试 `<meta property="og:title">`**
        if let metaTitleElement = try? document.select("meta[property=og:title]").first(),
           let metaTitle = try? metaTitleElement.attr("content"),
           !metaTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanedMetaTitle = metaTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            if isValidTitle(cleanedMetaTitle) { return cleanedMetaTitle }
        }

        // **3 依次尝试 `<h1>`、`<h2>`**
        let headingTags = ["h1", "h2"]
        for tag in headingTags {
            if let headingElement = try? document.select(tag).first(),
               let headingText = try? headingElement.text(),
               !headingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let cleanedHeading = headingText.trimmingCharacters(in: .whitespacesAndNewlines)
                if isValidTitle(cleanedHeading) { return cleanedHeading }
            }
        }

    } catch {
        print("HTML 解析失败: \(error.localizedDescription)")
    }
    
    // **4 默认返回国际化名称**
    let currentLanguage = Locale.preferredLanguages.first ?? "zh-Hans"
    return currentLanguage.hasPrefix("zh") ? "提供的网页" : "Provided Webpage"
}

// **辅助函数：过滤无意义的标题**
func isValidTitle(_ title: String) -> Bool {
    let invalidTitles = ["首页", "欢迎", "无标题", "Default Title", "Welcome", "Untitled", "Home"]
    return !invalidTitles.contains(where: { title.localizedCaseInsensitiveContains($0) })
}

// **提取网页主要内容**
func extractMainContent(from html: String) -> String {
    do {
        let document = try SwiftSoup.parse(html)
        
        // **1 尝试提取 `<article>`、`<main>`、`<section>`**
        let highPriorityTags = ["article", "main", "section"]
        var extractedText: String = ""

        for tag in highPriorityTags {
            if let element = try? document.select(tag).first(), let text = try? element.text(), text.count > 100 {
                extractedText.append("\n\n" + text)
                break
            }
        }

        // **2 降级到 `<div>` 和 `<p>`，排除 `ads` 类广告**
        if extractedText.isEmpty {
            if let elements = try? document.select("div, p").not("[class*=ads]") {
                for element in elements {
                    let text = try element.text()
                    if text.count > 50 {
                        extractedText.append("\n" + text)
                    }
                }
            }
        }
        
        // **3 如果仍然为空，则降级到整个网页文本**
        if extractedText.isEmpty {
            extractedText = try document.text()
        }
        
        // **4 清理换行、空格**
        extractedText = extractedText
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)

        // **5 限制正文长度**
        print("网页阅读：", String(extractedText))
        return String(extractedText)

    } catch {
        print("HTML 解析失败: \(error.localizedDescription)")
        return "网页解析失败"
    }
}

// **提取网页 Favicon**
func extractFavicon(from html: String, pageURL: URL) -> String {
    do {
        let document = try SwiftSoup.parse(html)

        // **1 优先解析 `<link rel="icon">` 或 `<link rel="shortcut icon">`**
        if let iconElement = try? document.select("link[rel~=(?i)shortcut icon|icon]").first(),
           let iconHref = try? iconElement.attr("href"),
           let faviconURL = resolveURL(iconHref, relativeTo: pageURL) {
            return faviconURL.absoluteString
        }

        // **2 其次解析 `<link rel="apple-touch-icon">`**
        if let appleTouchIcon = try? document.select("link[rel=apple-touch-icon]").first(),
           let appleTouchHref = try? appleTouchIcon.attr("href"),
           let appleTouchURL = resolveURL(appleTouchHref, relativeTo: pageURL) {
            return appleTouchURL.absoluteString
        }

        // **3 尝试从 `meta[property="og:image"]` 提取**
        if let ogImage = try? document.select("meta[property=og:image]").first(),
           let ogImageHref = try? ogImage.attr("content"),
           let ogImageURL = resolveURL(ogImageHref, relativeTo: pageURL) {
            return ogImageURL.absoluteString
        }

    } catch {
        print("⚠️ HTML 解析失败: \(error.localizedDescription)")
    }
    
    // **4 默认回退到 `/favicon.ico`**
    return "\(pageURL.scheme ?? "https")://\(pageURL.host ?? "")/favicon.ico"
}

// **辅助函数：解析 `href` 相对路径**
func resolveURL(_ href: String, relativeTo baseURL: URL) -> URL? {
    if href.hasPrefix("http") { return URL(string: href) } // 绝对 URL 直接返回
    return URL(string: href, relativeTo: baseURL)?.absoluteURL // 解析相对路径
}
