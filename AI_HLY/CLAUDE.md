# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Swift-based iOS application called "AI翰林院" (AI Hanlin Academy). The app is a comprehensive AI assistant tool that integrates multiple AI models and services, including chat, vision analysis, knowledge management, and various specialized tools.

## Build and Development Commands

### Opening the Project
```bash
# Open the Xcode project (located in parent directory)
open ../AI_HLY.xcodeproj
```

### Build Commands
- Build using Xcode's standard build system (⌘+B)
- Run on simulator or device (⌘+R)
- Clean build folder: Product → Clean Build Folder (⌘+Shift+K)

### Key Dependencies (Swift Package Manager)
The project uses several external dependencies managed through SPM:
- **LLM.swift** (v1.8.0) - Core LLM integration library
- **CoreXLSX** (v0.14.2) - Excel file processing
- **LaTeXSwiftUI** (v1.5.0) - LaTeX rendering in SwiftUI
- **MarkdownUI** - Markdown rendering support
- **SwiftSoup** - HTML parsing
- **RichTextKit** - Rich text editing capabilities
- **ZIPFoundation** - Archive handling

## Architecture

### Core App Structure

The app follows a tab-based architecture with SwiftData for persistence:

1. **App Entry Point**: `AI_HLY.swift`
   - Sets up SwiftData `ModelContainer` with CloudKit integration
   - Configures all data models and preloads default data
   - Handles deep linking for VisionView

2. **Main Navigation**: `MainTabView.swift`
   - Five-tab structure: Chat List, Vision, Knowledge, Models, Settings
   - Deep link handling for external app integration

3. **Core Views**:
   - `ListView.swift` - Chat conversation management
   - `ChatView.swift` - Individual chat interface with streaming responses
   - `VisionView.swift` - Camera-based OCR and image analysis
   - `KnowledgeListView.swift` - Knowledge base management
   - `ModelsView.swift` - AI model selection and configuration
   - `SettingsView.swift` - App configuration and API key management

### Data Architecture (SwiftData)

All models are defined with `@Model` and support CloudKit sync:

- **Core Chat Models**:
  - `ChatRecords` - Conversation metadata and settings
  - `ChatMessages` - Individual messages with rich content support
  - `MemoryArchive` - Long-term conversation memory

- **Configuration Models**:
  - `AllModels` - AI model definitions with capabilities (multimodal, reasoning, tool use, etc.)
  - `APIKeys` - Encrypted API key storage for various providers
  - `SearchKeys` - Search engine API configurations
  - `ToolKeys` - Tool-specific API keys and settings

- **Knowledge Management**:
  - `KnowledgeRecords` - Knowledge base metadata
  - `KnowledgeChunk` - Chunked knowledge content for RAG

- **User Data**:
  - `UserInfo` - User preferences and settings
  - `PromptRepo` - Custom prompt templates
  - `TranslationDic` - Translation dictionaries

### Service Layer Architecture

Services are organized by functionality in `/Services`:

1. **APIServices**:
   - `APIManager.swift` - Core API communication with streaming support
   - `APIBalance.swift` - API usage tracking and billing
   - `APITest.swift` - API endpoint validation

2. **ChatServices** - Tool ecosystem:
   - `ChatTools.swift` - Tool registration and orchestration
   - `ToolsAPI.swift` - Tool execution framework
   - `WebSearchTool.swift` - Multi-provider web search
   - `WebReadTool.swift` - Web content extraction
   - `MapServices.swift` - Location and mapping integration
   - `WeatherServices.swift` - Weather data integration
   - `CalendarService.swift` - Calendar integration
   - `HealthServices.swift` - HealthKit integration
   - `CodeServices.swift` - Code analysis and execution
   - `CanvasServices.swift` - Drawing and visual tools
   - `TextToSpeech.swift` - Voice synthesis

3. **Specialized Services**:
   - `ModelServices` - Model management and local inference
   - `KnowledgeServices` - RAG implementation and knowledge retrieval
   - `VisionServices` - Image analysis and OCR
   - `DataServices` - Data preloading and system optimization

### Key Architectural Patterns

1. **Streaming Response Handling**:
   - `StreamData` struct defines all possible streaming content types
   - `APIManager` handles async streaming with tool orchestration
   - Real-time UI updates via `@Published` properties

2. **Tool System Architecture**:
   - Tools are registered in `ChatTools.swift` with metadata
   - `ToolsAPI.swift` provides execution framework
   - Tools can return structured data (locations, images, documents, etc.)

3. **Model Capability System**:
   - `AllModels` defines capabilities per model (multimodal, reasoning, tool use)
   - Dynamic UI adaptation based on model capabilities
   - Support for both cloud and local models

4. **Multi-Provider Integration**:
   - Supports 20+ AI providers (OpenAI, Claude, Qwen, DeepSeek, etc.)
   - Unified API abstraction in `APIManager`
   - Provider-specific icon and branding support

## Development Workflow

### Adding New AI Models
1. Add model definition in `AllModels.swift` with capabilities
2. Implement API integration in `APIManager.swift`
3. Add provider icon to Assets.xcassets
4. Update `ModelsView.swift` for UI support

### Adding New Tools
1. Implement tool logic in appropriate service file under `ChatServices/`
2. Register tool in `ChatTools.swift` with metadata
3. Add API key configuration if needed in `APIKeys.swift`
4. Update settings UI in `SettingsView.swift`

### Working with SwiftData
- All models support CloudKit sync automatically
- Use `@Query` for reactive data binding
- Preload default data in `AppDataManager.preloadDataIfNeeded()`
- Handle data migrations in model definitions

### UI Component Patterns
- Reusable components are in `/Views/Components/`
- Follow SwiftUI best practices with `@StateObject` and `@ObservedObject`
- Support both light and dark themes
- Extensive use of SF Symbols for icons

## Resource Management

- **Assets**: Extensive icon library for 20+ AI providers with dark mode variants
- **Localization**: Multi-language support via Localizable.xcstrings
- **Configuration Files**: JSON configs for memory system and refinement prompts
- **Launch Screen**: Storyboard-based launch screen with localization