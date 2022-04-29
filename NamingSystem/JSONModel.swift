//
//   Copyright © 2022 S.M. Technology Ltd. All rights reserved.
//

import Cocoa

public enum DecoderType: Int {
    case swiftDecoder = 0
    case swiftyJSON = 1
}

//TODO: FIX value type is `Array` loop Implement issue
public class JSONModel: NSObject {
    public var fileName = "DefaultFileName"
    public var name: String
    public var key: String
    public var level:Int = 0
    public var values: [String: ModelValue] = [String: ModelValue]()
    
    public init(dictionary: Dictionary<String, Any>, name: String, key: String, level: Int) {
        self.key = key
        self.name = name
        self.level = level
        
        for key in dictionary.keys {
            var value: ModelValue = ModelValue(key: key, value: dictionary[key])
            if (value.type == .dictionary) {
                let model = JSONModel.init(dictionary: dictionary[key] as! Dictionary<String, Any>, name: "\(name)\(key.nameFromat)", key: key, level: level + 1)
                value.changeValue(newValue: model)
            }
            if (value.type == .array) {
                guard let ds = value.value as? [Any] else {return}
                var models: [Any] = []
                for d in ds {
                    if let dict = d as? Dictionary<String, Any> {
                        let childName = "\(name)\(key.nameFromat)"
                        let model = JSONModel(dictionary: dict, name: childName, key: key, level: level + 1)
                        models.append(model)
                    }else{
                        models.append(ModelValue(key: key, value: d))
                    }
                }
                value.changeValue(newValue: models)
            }
            values[key] = value
        }
    }
}

extension JSONModel {
    public func createModelString(type: DecoderType, isIncludedHeader: Bool = false) -> String {
        var text: String = ""
        if (self.level == 0) {
            fileName = "\(name).swift"
            if isIncludedHeader {
                text.append(creatCopyrightString(type: type))
            }
        }
        return "\(text)\(createStruct(text: text, type: type))"
    }
    
    //copy right string
    private func creatCopyrightString(type: DecoderType) -> String {
        let importSwityJsonLibrary = type == .swiftyJSON ? "\nimport SwiftyJSON" : ""
        return "//\n//  \(fileName)\n//\n//  Created by Naming Machine on \(getTimeString()).\n//  Copyright © \(getYearString()). All rights reserved.\n//\n\nimport Foundation\(importSwityJsonLibrary)\n\n"
    }
    
    private func getTimeString() -> String {
        let formate: DateFormatter = DateFormatter()
        formate.timeZone = Calendar.current.timeZone
        formate.dateFormat = "yyyy/MM/dd"
        return formate.string(from: Date())
    }
    
    private func getYearString() -> String {
        let formate: DateFormatter = DateFormatter()
        formate.timeZone = Calendar.current.timeZone
        formate.dateFormat = "yyyy"
        return formate.string(from: Date())
    }
    
    private func createStruct(text: String, type: DecoderType) -> String {
        let newText = createStructProperty(text: text, type: type)
        var impText: String = ""
        if type == .swiftyJSON { impText = createStructImplementForSwityJSOnN(text: newText) }
        if type == .swiftDecoder { impText = createStructImplementForSwitDecoder(text: newText) }
        
        for value in self.values {
            switch value.value.type {
            case .dictionary:
                if let jm = value.value.value as? JSONModel {
                    impText = "\(impText)\n\n\(jm.createStruct(text: impText, type: type))"
                }
            case .array:
                if let jm = value.value.value as? [JSONModel] {
                    if jm.count > 0 {
                        impText = "\(impText)\n\n\(jm[0].createStruct(text: impText, type: type))"
                    }
                }
            default:
                print("No need to create struct")
            }
        }
        return impText
    }
    
    private func createStructProperty(text: String, type: DecoderType) -> String {
        var text: String = "struct \(name): Decodable {\n"
        for value in self.values {
            switch value.value.type {
            case .int, .double, .string, .bool:
                text.append("    var \(value.key): \(value.value.type.rawValue)?\n")
            case .dictionary:
                if let jm = value.value.value as? JSONModel {
                    text.append("    var \(value.key): \(jm.name)?\n")
                }
            case .array:
                if let jm = value.value.value as? [JSONModel] {
                    if jm.count > 0 {
                        text.append("    var \(value.key): [\(jm[0].name)] = []\n")
                    }
                }
                if let jms = value.value.value as? [ModelValue] {
                    if jms.count > 0 {
                        text.append("    var \(value.key): [\(jms[0].type.rawValue)] = []\n")
                    }else{
                        text.append("    var \(value.key): [SpecifyYourObjectType] = []\n")
                    }
                }
            default:
                text.append("    var \(value.key): SpecifyTypeHere?\n")
            }
        }
        return "\(text)\n"
    }
    
    private func createStructImplementForSwityJSOnN(text: String) -> String {
        var newText: String = text
        newText.append("    //Get the \(name) model instence\n    static func decode(json: JSON) -> \(name) {\n        var object = \(name)()\n")
        
        
        for value in self.values {
            switch value.value.type {
                
            case .int, .double, .string, .bool:
                newText.append("        object.\(value.value.key) = json[\"\(value.value.key)\"].\(value.value.type.rawValue.lowercased())\n")
            case .dictionary:
                if let jm = value.value.value as? JSONModel {
                    newText.append("        object.\(value.value.key) = \(jm.name).decode(json: json[\"\(value.value.key)\"])\n")
                }
            case .array:
                
                //content is dictionary
                if let jms = value.value.value as? [JSONModel], jms.count > 0 {
                    
                    newText.append("\n        //Array Value\n        if let js = json[\"\(value.value.key)\"].array {\n            var items: [\(jms[0].name)] = [\(jms[0].name)]()\n            for j in js {items.append(\(jms[0].name).decode(json:j))}        \n            object.\(value.value.key) = items\n        }\n")
                    
                }
                
                //content is none dictionary
                if let jms = value.value.value as? [ModelValue] {
                    if jms.count > 0 {
                        newText.append("\n        //Array Value Type: \(jms[0].type.rawValue)\n        if let js = json[\"\(value.value.key)\"].array {\n            var items: [\(jms[0].type.rawValue)] = [\(jms[0].type.rawValue)]()\n            for j in js {items.append(j.\(jms[0].type.rawValue.lowercased()) ?? \"\")}        \n            object.\(value.value.key) = items\n        }\n")
                    }else{
                        newText.append("        object.\(value.value.key) = []\n")
                    }
                }
                
            default:
                newText.append("        object.\(value.value.key) = json[\"\(value.value.key)\"].SpecifyYourValueType\n")
            }
        }
        newText.append("        return object\n")
        return "\(newText)    }\n}\n\n"
    }
    
    private func createStructImplementForSwitDecoder(text: String) -> String {
        var newText: String = text
        newText.append("    enum CodingKeys: String, CodingKey {\n")
        for value in values {
            newText.append("        case \(value.key)\n")
        }
        newText.append("    }\n\n")
        newText.append("    init(from decoder: Decoder) throws {\n")
        newText.append("        let container = try decoder.container(keyedBy: CodingKeys.self)\n")
        for value in values {
            switch value.value.type {
            case .string:
                newText.append("        \(value.value.key) = try container.decode(String.self, forKey: .\(value.value.key))\n")
            case .int:
                newText.append("        \(value.value.key) = try container.decode(Int.self, forKey: .\(value.value.key))\n")
            case .bool:
                newText.append("        \(value.value.key) = try container.decode(Bool.self, forKey: .\(value.value.key))\n")
            case .double:
                newText.append("        \(value.value.key) = try container.decode(Double.self, forKey: .\(value.value.key))\n")
            case .dictionary:
                if let jsonModel = value.value.value as? JSONModel {
                    newText.append("        \(value.value.key) = try container.decode(\(jsonModel.name).self, forKey: .\(value.value.key))\n")
                }
            case .array:
                if let jsonModelArray = value.value.value as? [JSONModel], jsonModelArray.count > 0 {
                    newText.append("        \(value.value.key) = try container.decode([\(jsonModelArray[0].name)].self, forKey: .\(value.value.key))\n")
                }
                if let jms = value.value.value as? [ModelValue] {
                    if jms.count > 0 {
                        newText.append("        \(value.value.key) = try container.decode([\(jms[0].type.rawValue)].self, forKey: .\(value.value.key))\n")
                    }else{
                        newText.append("        \(value.value.key) = []\n")
                    }
                }
            default:
                newText.append("        \(value.value.key) = try container.decode(YOUHAVETOSPECIFYANAME.self, forKey: .\(value.value.key))\n")
            }
        }
        newText.append("    }\n\n")
        newText.append("    static func toOption(From data: Data) -> \(name)? {\n")
        newText.append("        return try? JSONDecoder().decode(\(name).self, from: data)\n")
        newText.append("    }\n")
        newText.append("}")
        return newText
    }
}
