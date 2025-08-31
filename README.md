# AI翰林院 (AI Hanlin)

<div align="center">

![AI翰林院](logo_3_0.png)

**一款集成多种AI模型和服务的综合性iOS应用**  
*A comprehensive iOS application integrating multiple AI models and services*

[![iOS](https://img.shields.io/badge/iOS-18.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SwiftData](https://img.shields.io/badge/SwiftData-Support-purple.svg)](https://developer.apple.com/xcode/swiftdata/)
[![CloudKit](https://img.shields.io/badge/CloudKit-Sync-blue.svg)](https://developer.apple.com/icloud/cloudkit/)

</div>

## ✨ 特性 Features

### 🤖 AI模型集成 AI Model Integration
- **20+ AI服务商支持**: OpenAI、Claude、Google Gemini、Qwen、DeepSeek、Kimi、智谱AI等
- **多模态能力**: 文本对话、图像分析、代码生成、文档理解
- **实时流式响应**: 支持流式对话，提供实时交互体验
- **本地模型支持**: 支持本地AI模型推理

### 🔧 智能工具生态 Intelligent Tool Ecosystem
- **📱 网络搜索**: 集成多个搜索引擎API (Google、Bing、DuckDuckGo等)
- **🌐 网页阅读**: 智能网页内容提取和分析
- **🗺️ 地图服务**: 百度地图集成，位置查询和导航
- **🌤️ 天气查询**: 实时天气信息和预报
- **📅 日历集成**: 日程管理和提醒功能
- **💪 健康数据**: HealthKit集成，健康数据分析
- **💻 代码服务**: 代码分析、执行和优化
- **🎨 画布工具**: 绘图和可视化工具
- **🔊 语音合成**: 文字转语音功能

### 📚 知识库管理 Knowledge Base Management
- **RAG系统**: 基于检索增强生成的知识库问答
- **文档支持**: 支持多种文档格式 (PDF、Word、Excel、Markdown等)
- **知识分块**: 智能文档分析和向量化存储
- **CloudKit同步**: 知识库云端同步

### 👁️ 视觉分析 Vision Analysis
- **OCR文字识别**: 相机实时文字识别和提取
- **图像分析**: AI驱动的图像内容理解
- **多语言支持**: 支持多种语言的文字识别

### 🎯 其他特性 Additional Features
- **SwiftData持久化**: 现代化的数据存储和管理
- **CloudKit同步**: 跨设备数据同步
- **深色模式**: 完整的明暗主题支持
- **国际化**: 多语言界面支持
- **隐私保护**: API密钥本地加密存储

## 🛠️ 技术栈 Tech Stack

- **开发语言**: Swift 5.9+
- **UI框架**: SwiftUI
- **数据存储**: SwiftData + CloudKit
- **网络请求**: URLSession + Async/Await
- **依赖管理**: Swift Package Manager

### 主要依赖 Main Dependencies

```swift
// 核心AI库
.package(url: "https://github.com/otabuzzman/LLM.swift", from: "1.8.0")

// 文档处理
.package(url: "https://github.com/CoreOffice/CoreXLSX", from: "0.14.2")
.package(url: "https://github.com/blackhole89/LaTeXSwiftUI", from: "1.5.0")
.package(url: "https://github.com/gonzalezreal/MarkdownUI", from: "2.0.0")

// 文本和UI
.package(url: "https://github.com/RichTextFormat/RichTextKit", from: "0.9.0")
.package(url: "https://github.com/scinfu/SwiftSoup", from: "2.6.0")

// 工具库
.package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.0")
```

## 🚀 快速开始 Quick Start

### 环境要求 Requirements
- iOS 18.0+
- Xcode 15.0+
- Swift 5.9+
- macOS 14.0+ (for development)

### 安装步骤 Installation

1. **克隆项目 Clone the repository**
   ```bash
   git clone https://github.com/yourusername/AI_HLY.git
   cd AI_HLY
   ```

2. **打开项目 Open the project**
   ```bash
   open AI_HLY.xcodeproj
   ```

3. **配置签名 Configure signing**
   - 在Xcode中选择你的开发团队
   - 修改Bundle Identifier为唯一值

4. **运行项目 Run the project**
   - 选择目标设备或模拟器
   - 按 `Cmd + R` 运行项目

### API配置 API Configuration

1. 运行应用并进入"设置"页面
2. 在"API密钥管理"中配置你需要的AI服务商API密钥：
   - OpenAI API Key
   - Claude API Key
   - Google Gemini API Key
   - 其他服务商密钥...

3. 在"工具配置"中设置外部服务API：
   - 搜索引擎API密钥
   - 地图服务密钥
   - 天气服务密钥

## 📖 使用指南 Usage Guide

### 基础对话 Basic Chat
1. 点击"列表"标签页
2. 点击"+"按钮创建新对话
3. 选择AI模型和配置参数
4. 开始对话

### 视觉分析 Vision Analysis
1. 点击"视觉"标签页
2. 使用相机拍摄包含文字的图像
3. 应用会自动识别并提取文字
4. 可以进一步对图像进行AI分析

### 知识库管理 Knowledge Management
1. 点击"知识库"标签页
2. 创建新的知识库
3. 上传文档或手动输入知识
4. 在对话中引用知识库进行问答

## 🏗️ 项目架构 Architecture

### 目录结构 Directory Structure
```
AI_HLY/
├── AI_HLY/                    # 主应用目录
│   ├── Views/                 # 视图组件
│   │   ├── MainTabView.swift
│   │   ├── ChatView.swift
│   │   ├── VisionView.swift
│   │   └── ...
│   ├── Models/                # 数据模型
│   │   ├── ChatRecords.swift
│   │   ├── AllModels.swift
│   │   └── ...
│   ├── Services/              # 服务层
│   │   ├── APIServices/
│   │   ├── ChatServices/
│   │   └── ...
│   └── Resources/             # 资源文件
├── AI_HLY.xcodeproj/         # Xcode项目文件
└── README.md
```

### 核心组件 Core Components

1. **应用入口** (`AI_HLY.swift`)
   - SwiftData模型容器初始化
   - CloudKit配置
   - 深度链接处理

2. **主界面** (`MainTabView.swift`)
   - 五个标签页导航
   - 深度链接路由

3. **数据层** (`Models/`)
   - SwiftData模型定义
   - CloudKit集成
   - 数据持久化

4. **服务层** (`Services/`)
   - API通信管理
   - 工具系统集成
   - 外部服务集成

## 📄 许可证 License

本项目采用 MIT 许可证。查看 [LICENSE](LICENSE) 文件了解详细信息。

## 🙏 致谢 Acknowledgments

- 感谢所有AI服务提供商的支持
- 感谢开源社区提供的优秀库和工具
- 感谢所有贡献者的努力

## 📞 联系方式 Contact

- 项目维护者: 哆啦好多梦

---

<div align="center">

**如果这个项目对你有帮助，请给它一个 ⭐️！**  
*If this project helps you, please give it a ⭐️!*

Made with ❤️ by the AI_HLY team

</div>