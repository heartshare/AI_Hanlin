//
//  WeatherServices.swift
//  AI_Hanlin
//
//  Created by 哆啦好多梦 on 14/5/25.
//

import Foundation
import CoreLocation

// MARK: - 天气查询
func queryWeatherDescription(
    at coordinate: CLLocationCoordinate2D,
    company: String,
    timeRange: String = "now",
    apiKey: String = "",
    requestURL: String = ""
) async throws -> String {
    switch company.uppercased() {
    case "QWEATHER":
        return try await queryWeatherDescriptionFromHeFeng(
            coordinate: coordinate,
            timeRange: timeRange,
            apiKey: apiKey,
            requestURL: requestURL
        )
    case "OPENWEATHER":
        // OpenWeather One Call 3.0 要求 appid 参数
        guard !apiKey.isEmpty else {
            throw WeatherError.missingAPIKey
        }
        // 默认 Host 为 api.openweathermap.org
        let host = requestURL.isEmpty
        ? "api.openweathermap.org"
        : requestURL
        return try await queryWeatherDescriptionFromOpenWeather(
            coordinate: coordinate,
            timeRange: timeRange,
            apiKey: apiKey,
            requestURL: host
        )
    default:
        return try await queryWeatherDescriptionFromHeFeng(
            coordinate: coordinate,
            timeRange: timeRange,
            apiKey: apiKey,
            requestURL: requestURL
        )
    }
}

// 和风天气
private func queryWeatherDescriptionFromHeFeng(
    coordinate: CLLocationCoordinate2D,
    timeRange: String,
    apiKey: String,
    requestURL: String
) async throws -> String {
    // 1. 构造 Host 与 Endpoint
    let host = requestURL.hasPrefix("https")
        ? requestURL
        : "https://\(requestURL)"
    let endpoint: String
    if timeRange == "now" {
        endpoint = "/v7/weather/now"         // 实时天气接口
    } else {
        endpoint = "/v7/weather/\(timeRange)" // 多日预报接口
    }
    
    // 2. 构造请求 URL（含定位、语言、单位）
    let lat = coordinate.latitude
    let lon = coordinate.longitude
    let isChinese = Locale.preferredLanguages.first?.hasPrefix("zh") ?? false
    let langParam = isChinese ? "zh" : "en"
    let unitParam = "m"
    let urlStr = "\(host)\(endpoint)?location=\(lon),\(lat)&key=\(apiKey)&lang=\(langParam)&unit=\(unitParam)"
    guard let url = URL(string: urlStr) else {
        throw WeatherError.badURL
    }
    
    // 3. 发起网络请求
    let (data, _) = try await URLSession.shared.data(from: url)
    let anyJson = try JSONSerialization.jsonObject(with: data, options: [])
    guard let dict = anyJson as? [String: Any] else {
        throw WeatherError.parsingFailed
    }
    
    var lines: [String] = []
    
    if timeRange == "now" {
        // —— 实时天气 解析
        guard let now = dict["now"] as? [String: Any] else {
            throw WeatherError.parsingFailed
        }
        let temp      = now["temp"]       ?? "--"
        let feelsLike = now["feelsLike"] ?? "--"
        let text      = now["text"]      ?? "--"
        let windDir   = now["windDir"]   ?? "--"
        let windScale = now["windScale"] ?? "--"
        let windSpeed = now["windSpeed"] ?? "--"
        let humidity  = now["humidity"]  ?? "--"
        let pressure  = now["pressure"]  ?? "--"
        let vis       = now["vis"]       ?? "--"
        let precip    = now["precip"]    ?? "--"
        let cloud     = now["cloud"]     ?? "--"
        let dew       = now["dew"]       ?? "--"
        let obsTime   = (now["obsTime"] as? String)?.split(separator: "T").last.map { String($0.prefix(5)) } ?? ""
        
        if isChinese {
            lines.append("当前天气：\(text)，温度 \(temp)℃，体感 \(feelsLike)℃")
            lines.append("风力：\(windDir)，\(windSpeed) km/h（\(windScale)级）")
            lines.append("湿度：\(humidity)%；气压：\(pressure) hPa")
            lines.append("能见度：\(vis) 公里；降水：\(precip) mm")
            if let c = cloud as? String, c != "--" {
                lines.append("云量：\(c)%")
            }
            if let d = dew as? String, d != "--" {
                lines.append("露点温度：\(d)℃")
            }
            if !obsTime.isEmpty {
                lines.append("数据更新时间：\(obsTime)\n数据来源：和风天气")
            }
        } else {
            lines.append("Current weather: \(text), temp \(temp)℃, feels like \(feelsLike)℃")
            lines.append("Wind: \(windDir), \(windSpeed) km/h (scale \(windScale))")
            lines.append("Humidity: \(humidity)%; Pressure: \(pressure) hPa")
            lines.append("Visibility: \(vis) km; Precipitation: \(precip) mm")
            if let c = cloud as? String, c != "--" {
                lines.append("Cloud cover: \(c)%")
            }
            if let d = dew as? String, d != "--" {
                lines.append("Dew point: \(d)℃")
            }
            if !obsTime.isEmpty {
                lines.append("Data updated at \(obsTime)\nSource: QWeather")
            }
        }
        
    } else {
        // —— 多日预报 解析
        guard let daily = dict["daily"] as? [[String: Any]] else {
            throw WeatherError.parsingFailed
        }
        for day in daily {
            guard
                let fxDate     = day["fxDate"]     as? String,
                let textDay    = day["textDay"]    as? String,
                let textNight  = day["textNight"]  as? String,
                let tempMax    = day["tempMax"]    as? String,
                let tempMin    = day["tempMin"]    as? String,
                let precip     = day["precip"]     as? String,
                let uvIndex    = day["uvIndex"]    as? String,
                let windDirDay = day["windDirDay"] as? String,
                let windScaleDay = day["windScaleDay"] as? String,
                let windSpeedDay = day["windSpeedDay"] as? String
            else {
                continue
            }
            
            if isChinese {
                lines.append("—— \(fxDate) ——")
                lines.append("白天：\(textDay)，最高 \(tempMax)℃；风力 \(windDirDay)\(windScaleDay)级（\(windSpeedDay) km/h）")
                lines.append("夜间：\(textNight)，最低 \(tempMin)℃")
                lines.append("降水：\(precip) mm；紫外线强度：\(uvIndex)")
            } else {
                lines.append("—— \(fxDate) ——")
                lines.append("Day: \(textDay), high \(tempMax)℃; Wind: \(windDirDay) \(windScaleDay) scale (\(windSpeedDay) km/h)")
                lines.append("Night: \(textNight), low \(tempMin)℃")
                lines.append("Precipitation: \(precip) mm; UV index: \(uvIndex)")
            }
        }
    }
    
    return lines.joined(separator: "\n")
}

// OpenWeather
private func queryWeatherDescriptionFromOpenWeather(
    coordinate: CLLocationCoordinate2D,
    timeRange: String,
    apiKey: String,
    requestURL: String
) async throws -> String {
    // 1. 基本配置
    let baseURL = requestURL.isEmpty
        ? "https://api.openweathermap.org"
        : (requestURL.hasPrefix("http") ? requestURL : "https://\(requestURL)")
    let lat = coordinate.latitude
    let lon = coordinate.longitude
    let isChinese = Locale.preferredLanguages.first?.hasPrefix("zh") ?? false
    let langParam = isChinese ? "zh_cn" : "en"
    let unitParam = "metric"
    
    // 2. 生成 URLComponents
    var comps: URLComponents
    switch timeRange.lowercased() {
    case "now":
        comps = URLComponents(string: "\(baseURL)/data/2.5/weather")!
        comps.queryItems = [
            URLQueryItem(name: "lat",   value: "\(lat)"),
            URLQueryItem(name: "lon",   value: "\(lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: unitParam),
            URLQueryItem(name: "lang",  value: langParam)
        ]
        
    case "3d", "7d", "10d", "15d", "30d":
        // cnt 参数按请求天数设置，OpenWeather /forecast/daily 支持最大 cnt=16
        let cnt: Int = {
            switch timeRange.lowercased() {
            case "3d":   return 3
            case "7d":   return 7
            case "10d":  return 10
            default:     return 15
            }
        }()
        comps = URLComponents(string: "\(baseURL)/data/2.5/forecast/daily")!
        comps.queryItems = [
            URLQueryItem(name: "lat",   value: "\(lat)"),
            URLQueryItem(name: "lon",   value: "\(lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "cnt",   value: "\(cnt)"),
            URLQueryItem(name: "units", value: unitParam),
            URLQueryItem(name: "lang",  value: langParam)
        ]
        
    default:
        // 兜底到“实时”
        comps = URLComponents(string: "\(baseURL)/data/2.5/weather")!
        comps.queryItems = [
            URLQueryItem(name: "lat",   value: "\(lat)"),
            URLQueryItem(name: "lon",   value: "\(lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: unitParam),
            URLQueryItem(name: "lang",  value: langParam)
        ]
    }
    
    guard let url = comps.url else {
        throw WeatherError.badURL
    }
    
    // 3. 发起请求并检查状态码
    let (data, resp) = try await URLSession.shared.data(from: url)
    guard let http = resp as? HTTPURLResponse else {
        throw WeatherError.parsingFailed
    }
    switch http.statusCode {
    case 200:
        break
    case 401:
        // 授权不足，提示订阅
        throw WeatherError.subscriptionRequired
    default:
        throw WeatherError.parsingFailed
    }
    
    // 4. 解析 JSON
    let anyJson = try JSONSerialization.jsonObject(with: data, options: [])
    var lines: [String] = []
    
    if timeRange.lowercased() == "now" {
        // —— 实时天气 (/weather)
        guard
            let dict       = anyJson as? [String: Any],
            let weatherArr = dict["weather"] as? [[String: Any]],
            let desc       = weatherArr.first?["description"] as? String,
            let main       = dict["main"]    as? [String: Any]
        else {
            throw WeatherError.parsingFailed
        }
        let temp      = (main["temp"]       as? Double).map { String(format: "%.1f", $0) } ?? "--"
        let feelsLike = (main["feels_like"] as? Double).map { String(format: "%.1f", $0) } ?? "--"
        let humidity  = (main["humidity"]   as? Double).map { String(format: "%.0f", $0) } ?? "--"
        let pressure  = (main["pressure"]   as? Double).map { String(format: "%.0f", $0) } ?? "--"
        let windSpeed = ( (dict["wind"] as? [String: Any])?["speed"] as? Double )
                            .map { String(format: "%.1f", $0) } ?? "--"
        let clouds    = ( (dict["clouds"] as? [String: Any])?["all"] as? Double )
                            .map { String(format: "%.0f", $0) } ?? "--"
        let dt        = dict["dt"] as? TimeInterval ?? 0
        let timeStr   = DateFormatter().apply {
                            $0.dateFormat = "yyyy-MM-dd HH:mm"
                        }.string(from: Date(timeIntervalSince1970: dt))
        
        if isChinese {
            lines.append("当前天气：\(desc)，温度 \(temp)℃，体感 \(feelsLike)℃")
            lines.append("湿度：\(humidity)%；气压：\(pressure) hPa")
            lines.append("风速：\(windSpeed) m/s；云量：\(clouds)%")
            lines.append("数据更新时间：\(timeStr)\n数据来源：OpenWeatherMap")
        } else {
            lines.append("Current weather: \(desc), temp \(temp)℃, feels like \(feelsLike)℃")
            lines.append("Humidity: \(humidity)%; Pressure: \(pressure) hPa")
            lines.append("Wind: \(windSpeed) m/s; Clouds: \(clouds)%")
            lines.append("Data updated at \(timeStr)\nSource: OpenWeatherMap")
        }
        
    } else {
        // —— 多日预报 (/forecast/daily)
        guard
            let dict = anyJson as? [String: Any],
            let list = dict["list"] as? [[String: Any]],
            !list.isEmpty
        else {
            throw WeatherError.parsingFailed
        }
        
        let df = DateFormatter().apply { $0.dateFormat = "yyyy-MM-dd" }
        for day in list {
            guard
                let dt    = day["dt"]  as? TimeInterval,
                let temp  = day["temp"] as? [String: Any],
                let maxT  = temp["max"] as? Double,
                let minT  = temp["min"] as? Double,
                let weatherArr = day["weather"] as? [[String: Any]],
                let desc  = weatherArr.first?["description"] as? String,
                let windSp   = day["speed"]    as? Double,
                let humidity = day["humidity"] as? Double
            else { continue }
            
            let dateStr = df.string(from: Date(timeIntervalSince1970: dt))
            let maxStr  = String(format: "%.1f", maxT)
            let minStr  = String(format: "%.1f", minT)
            let windStr = String(format: "%.1f", windSp)
            let humStr  = String(format: "%.0f", humidity)
            
            if isChinese {
                lines.append("—— \(dateStr) ——")
                lines.append("天气：\(desc)；最高 \(maxStr)℃，最低 \(minStr)℃")
                lines.append("风速：\(windStr) m/s；湿度：\(humStr)%")
            } else {
                lines.append("—— \(dateStr) ——")
                lines.append("Weather: \(desc); High \(maxStr)℃, Low \(minStr)℃")
                lines.append("Wind: \(windStr) m/s; Humidity: \(humStr)%")
            }
        }
    }
    
    return lines.joined(separator: "\n")
}

// 辅助：便于一行内配置 DateFormatter
fileprivate extension DateFormatter {
    func apply(_ block: (DateFormatter) -> Void) -> DateFormatter {
        block(self)
        return self
    }
}

/// 错误类型定义
enum WeatherError: Error, LocalizedError {
    case missingAPIKey
    case badURL
    case parsingFailed
    case subscriptionRequired   // ← 新增

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "缺少 API Key。"
        case .badURL:
            return "URL 构造失败。"
        case .parsingFailed:
            return "解析返回结果失败。"
        case .subscriptionRequired:
            return "调用该多日预报接口需要付费订阅 OpenWeatherMap 的高级权限。"
        }
    }
}
