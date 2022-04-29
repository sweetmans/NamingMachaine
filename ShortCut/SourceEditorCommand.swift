//
//   Copyright © 2022 S.M. Technology Ltd. All rights reserved.
//


import Foundation
import XcodeKit
import NamingSystem

private struct NASJSON {
    var name: String
    var json: String
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    private var jsonText: String?
    private var model: JSONModel?
    private var dicnaryObject: Dictionary<String, Any>?
    private var iSSourceJsonTextVaild: Bool = false
    private var rows: [JSONRow] = []
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selectedLines = getSeletedLines(from: invocation) as? [String],
              selectedLines.count > 0,
              let json = getJson(from: selectedLines, completionHandler: completionHandler) else {
            return completionHandler(nil)
        }
        let trimmedText = json.json.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        checkJSONTextIsVaildFormate(for: trimmedText, completionHandler: completionHandler)
        guard let d = dicnaryObject else { return completionHandler(ExtensionInternalError()) }
        let jsonModel = JSONModel(dictionary: d, name: json.name, key: json.name, level: 0)
        let modelText = jsonModel.createModelString(type: .swiftDecoder, isIncludedHeader: true)
        if let range = getSelctedLinesRange(from: invocation) {
            invocation.buffer.lines.removeObjects(in: range)
        }
        invocation.buffer.lines.addObjects(from: [modelText])
        completionHandler(nil)
    }
    
    private func getJson(from selectedLines: [String], completionHandler: @escaping (Error?) -> Void ) -> NASJSON? {
        var json: NASJSON? = nil
        let removedBlankLinesSelection = selectedLines.filter{ $0.replacingOccurrences(of: " ", with: "") != "\n" }
        var jsonStrings = removedBlankLinesSelection
        for (index, line) in removedBlankLinesSelection.enumerated() {
            if line.contains("name:") {
                let name = line.replacingOccurrences(of: "name:", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
                jsonStrings.remove(at: index)
                var jsonString: String = ""
                for line in jsonStrings {
                    jsonString.append(line)
                }
                json = NASJSON(name: name, json: jsonString)
                break
            }
        }
        if json == nil {
            completionHandler(FileNameNotProvidedError())
        }
        return json
    }
    
    private func getSeletedLines(from invocation: XCSourceEditorCommandInvocation)  -> [Any] {
        guard let range = getSelctedLinesRange(from: invocation) else { return [] }
        return invocation.buffer.lines.subarray(with: range)
    }
    
    private func getSelctedLinesRange(from invocation: XCSourceEditorCommandInvocation) -> NSRange? {
        guard let firstSelectedObject: XCSourceTextRange = invocation.buffer.selections.firstObject as? XCSourceTextRange else { return nil }
        let start = firstSelectedObject.start.line
        let end = min(firstSelectedObject.end.line, invocation.buffer.lines.count - 1)
        return NSRange(start...end)
    }
    
    private func checkJSONTextIsVaildFormate(for text: String, completionHandler: @escaping (Error?) -> Void ) {
        guard let data: Data = text.data(using: .utf8) else { return }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            rows = JSONRow.getAllRows(From: jsonObject)
            if  let object = jsonObject as? Dictionary<String, Any> {
                handleDictionaryObject(From: object)
            } else if let array = jsonObject as? [Any] {
                handleArrayObject(From: array)
            }
        } catch {
            completionHandler(IncorrectJSONFormatError())
        }
    }
    
    private func handleDictionaryObject(From dictionary: Dictionary<String, Any>) {
        model = JSONModel(dictionary: dictionary, name: "DefaultFileName", key: "DefaultFileName", level: 0)
        dicnaryObject = dictionary
        iSSourceJsonTextVaild = true
    }
    
    private func handleArrayObject(From object: [Any]) {
        if let firstObject = object.first {
            if  let object = firstObject as? Dictionary<String, Any> {
                handleDictionaryObject(From: object)
            }
            if let array = firstObject as? [Any] {
                handleArrayObject(From: array)
            }
        }
    }
}


struct FileNameNotProvidedError: Error {
    var localizedDescription: String = "File name not provided in first selected line."
}

struct IncorrectJSONFormatError: Error {
    var localizedDescription: String = "Wrong JSON Format"
}

struct ExtensionInternalError: Error {
    var localizedDescription: String = "Could not indentify errors"
}
