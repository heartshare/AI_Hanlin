//
//  DocumentPicker.swift
//  AI_HLY
//
//  Created by 哆啦好多梦 on 9/2/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedDocumentURLs: [URL] // 绑定多文档数组

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [
            UTType.pdf,
            UTType.commaSeparatedText,  // CSV
            UTType.pythonScript,        // .py
            UTType.plainText,           // .txt
            UTType.json,                // JSON
            UTType.log,                 // LOG
            UTType.html                 // HTML
        ] + [
            "docx", "xlsx", "pptx", "md"
        ].compactMap { UTType(filenameExtension: $0) } // 确保不会包含 nil 值

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true // 开启多选
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // 记录所有选择的文件路径
            parent.selectedDocumentURLs = urls
        }
    }
}


struct SingleDocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedDocumentURL: URL? // 单个文件 URL

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [
            UTType.pdf,
            UTType.commaSeparatedText,
            UTType.pythonScript,
            UTType.plainText,
            UTType.json,
            UTType.log,
            UTType.html
        ] + [
            "docx", "xlsx", "pptx", "md"
        ].compactMap { UTType(filenameExtension: $0) }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false // ❗️只允许单选
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: SingleDocumentPicker

        init(_ parent: SingleDocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let firstURL = urls.first else { return }
            parent.selectedDocumentURL = firstURL
        }
    }
}
