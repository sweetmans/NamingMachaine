//
//   Copyright © 2022 S.M. Technology Ltd. All rights reserved.
//

import Foundation
import NamingSystem
import AppKit

class JSONProvider {
    static let shared = JSONProvider()
    private var decoderType: DecoderType = .swiftDecoder
    private var dicnaryObject: Dictionary<String, Any>?
    
    func setDecoderType(type: DecoderType) {
        decoderType = type
    }
    
    func getDecoderType() -> DecoderType {
        decoderType
    }
    
    func setDicnaryObject(object: Dictionary<String, Any>?) {
        dicnaryObject = object
    }
    
    func getDicnaryObject() -> Dictionary<String, Any>? {
        dicnaryObject
    }
    
    func genarateFile(for fileName: String, url: URL) {
        guard let d = dicnaryObject else { return }
        let jsonModel = JSONModel(dictionary: d, name: fileName, key: fileName, level: 0)
        let modelText = jsonModel.createModelString(type: decoderType)
        guard let data = modelText.data(using: .utf8) else { return }
        do {
            try data.write(to: url)
            NSWorkspace.shared.open(url)
        } catch let error {
            ErrorHandler.showGenarateFileError()
            print(error)
        }
    }
    
    func showSavePanel() {
        if dicnaryObject == nil {
            ErrorHandler.showEmptyEmptyError()
            return
        }
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.title = "Generate Models From JSON Text"
        savePanel.message = "Enter Your Root Object Name To Start Generate Models"
        savePanel.prompt = "Save"
        savePanel.nameFieldLabel = "Root Object Name:"
        savePanel.nameFieldStringValue = "StoreFront"
        savePanel.showsTagField = false
        savePanel.allowedContentTypes = [.swiftSource]
        let result = savePanel.runModal()
        switch result {
        case .OK:
            let name = savePanel.nameFieldStringValue
            guard let saveURL = savePanel.url else {
                ErrorHandler.showCouldNotGetURLError()
                return
            }
            JSONProvider.shared.genarateFile(for: name, url: saveURL)
        default:
            print("save Panel is not show up")
        }
    }
}
