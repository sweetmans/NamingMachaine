//
//  Copyright © 2021 S.M. Technology. All rights reserved.
//

import Cocoa

struct JSONRow {
    var color: NSColor
    var level: Int
    var value: String
    var key: String
    
    static func getRowsFrom(dictionary: Dictionary<String, Any>, rootLevel: Int, rootKey: String) -> [JSONRow] {
        let subLevel = rootLevel + 1
        var rows: [JSONRow] = []
        rows.append(JSONRow(color: JSONRow.defaultColor, level: rootLevel, value: "{", key: rootKey))
        
        for object in dictionary {
            let value = ModelValue(key: object.key, value: object.value)
            switch value.type {
            case .string:
                rows.append(JSONRow(color: JSONRow.stringColor, level: rootLevel + 1, value: "\"\(value.value as! String)\",", key: value.key))
            case .double:
                rows.append(JSONRow(color: JSONRow.doubleColor, level: subLevel, value: "\(value.value ?? 0.0),", key: value.key))
            case .bool:
                let v = value.value as? Bool
                let vString = v == true ? "true" : "false"
                rows.append(JSONRow(color: JSONRow.boolColor, level: subLevel, value: "\(vString),", key: value.key))
            case .int:
                rows.append(JSONRow(color: JSONRow.intColor, level: subLevel, value: "\(value.value ?? 0),", key: value.key))
            case .null:
                rows.append(JSONRow(color: JSONRow.nilColor, level: subLevel, value: "null,", key: value.key))
            case .array:
                rows.append(contentsOf: JSONRow.getRowsFrom(array: value.value as? [Any] ?? [], rootLevel: subLevel, key: value.key))
            case .dictionary:
                rows.append(contentsOf: JSONRow.getRowsFrom(dictionary: value.value as? Dictionary<String, Any> ?? Dictionary<String, Any>.init(), rootLevel: subLevel, rootKey: value.key))
            default:
                print("Can't handle this situation")
            }
        }
        
        rows.append(JSONRow(color: JSONRow.defaultColor, level: rootLevel, value: rootLevel == 0 ? "}" : "},", key: ""))
        return rows
    }
    
    static func getRowsFrom(array: [Any], rootLevel: Int, key: String) -> [JSONRow]  {
        let subLevel = rootLevel + 1
        var rows: [JSONRow] = []
        
        if let first = array.first {
            rows.append(JSONRow(color: JSONRow.arrayColor, level: rootLevel, value: "[", key: key))
            let value = ModelValue(key: key, value: first)
            switch value.type {
            case .string:
                rows.append(JSONRow(color: JSONRow.stringColor, level: subLevel, value: "\"\(value.value as! String)\",", key: ""))
            case .double:
                rows.append(JSONRow(color: JSONRow.doubleColor, level: subLevel, value: "\(value.value ?? 0.0),", key: ""))
            case .bool:
                let v = value.value as? Bool
                let vString = v == true ? "true" : "false"
                rows.append(JSONRow(color: JSONRow.boolColor, level: subLevel, value: "\(vString),", key: ""))
            case .int:
                rows.append(JSONRow(color: JSONRow.intColor, level: subLevel, value: "\(value.value ?? 0),", key: ""))
            case .array:
                rows.append(contentsOf: JSONRow.getRowsFrom(array: value.value as? [Any] ?? [], rootLevel: subLevel, key: value.key))
            case .dictionary:
                rows.append(contentsOf: JSONRow.getRowsFrom(dictionary: value.value as? Dictionary<String, Any> ?? Dictionary<String, Any>.init(), rootLevel: subLevel, rootKey: value.key))
            case .null:
                rows.append(JSONRow(color: JSONRow.nilColor, level: subLevel, value: "null,", key: value.key))
            default:
                print("Can't handle this situation")
            }
            //insert:  `]` with empty key
            rows.append(JSONRow(color: JSONRow.arrayColor, level: rootLevel, value: rootLevel == 0 ? "]" : "],", key: ""))
        }else{
            rows.append(JSONRow(color: JSONRow.arrayColor, level: rootLevel, value: "[],", key: key))
        }
        
        return rows
    }
    
}

extension JSONRow {
    static var stringColor: NSColor { return .systemRed }
    static var doubleColor: NSColor { return .systemPurple }
    static var intColor: NSColor { return .systemPurple }
    static var boolColor: NSColor { return .systemPink }
    static var nilColor: NSColor { return .systemPink }
    static var defaultColor: NSColor { return .systemPurple }
    static var keyColor: NSColor { return .systemGreen }
    static var arrayColor: NSColor { return .systemOrange}
}
