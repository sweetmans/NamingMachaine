//
//  Copyright © 2021 S.M. Technology. All rights reserved.
//

import Cocoa

struct JSONRow {
    struct Measurements {
        static let heavyFont = NSFont(name: "Menlo Bold Italic", size: 14) ?? NSFont.systemFont(ofSize: 14)
        static var stringColor: NSColor { return .systemRed }
        static var doubleColor: NSColor { return .systemPurple }
        static var intColor: NSColor { return .systemPurple }
        static var boolColor: NSColor { return .systemPink }
        static var nilColor: NSColor { return .systemPink }
        static var defaultColor: NSColor { return .systemPurple }
        static var keyColor: NSColor { return .systemGreen }
        static var arrayColor: NSColor { return .systemOrange}
    }
    
    var color: NSColor
    var level: Int
    var value: String
    var key: String
    var font: NSFont = NSFont(name: "Menlo Bold", size: 13) ?? NSFont.systemFont(ofSize: 13)
    
    static func getAllRows(From object: Any) -> [JSONRow] {
        var jsonRows: [JSONRow] = []
        if let dictionary = object as? Dictionary<String, Any> {
            let rows = getRowsFromDictionary(dictionary: dictionary, rootLevel: 0, rootKey: "", fromArray: false)
            jsonRows.append(contentsOf: rows)
        }
        if let array = object as? [Any] {
            let rows = getRowsFrom(array: array, rootLevel: 0, key: "")
            jsonRows.append(contentsOf: rows)
        }
        return jsonRows
    }
    
    static func getRowsFromDictionary(dictionary: Dictionary<String, Any>,
                                      rootLevel: Int,
                                      rootKey: String,
                                      fromArray: Bool) -> [JSONRow] {
        let subLevel = rootLevel + 1
        var rows: [JSONRow] = []
        if fromArray {
            rows.append(JSONRow(color: Measurements.defaultColor, level: rootLevel, value: "{", key: "", font: Measurements.heavyFont))
        } else {
            rows.append(JSONRow(color: Measurements.defaultColor, level: rootLevel, value: "{", key: rootKey, font: Measurements.heavyFont))
        }
        for object in dictionary {
            let value = ModelValue(key: object.key, value: object.value)
            switch value.type {
            case .string:
                rows.append(JSONRow(color: Measurements.stringColor, level: rootLevel + 1, value: "\"\(value.value as! String)\"", key: value.key))
            case .double:
                rows.append(JSONRow(color: Measurements.doubleColor, level: subLevel, value: "\(value.value ?? 0.0)", key: value.key))
            case .bool:
                let v = value.value as? Bool
                let vString = v == true ? "true" : "false"
                rows.append(JSONRow(color: Measurements.boolColor, level: subLevel, value: "\(vString)", key: value.key))
            case .int:
                rows.append(JSONRow(color: Measurements.intColor, level: subLevel, value: "\(value.value ?? 0)", key: value.key))
            case .null:
                rows.append(JSONRow(color: Measurements.nilColor, level: subLevel, value: "null", key: value.key))
            case .array:
                rows.append(contentsOf: JSONRow.getRowsFrom(array: value.value as? [Any] ?? [], rootLevel: subLevel, key: value.key))
            case .dictionary:
                rows.append(contentsOf: JSONRow.getRowsFromDictionary(dictionary: value.value as? Dictionary<String, Any> ?? Dictionary<String, Any>.init(), rootLevel: subLevel, rootKey: value.key, fromArray: false))
            default:
                print("Can't handle this situation")
            }
        }
        rows.append(JSONRow(color: Measurements.defaultColor, level: rootLevel, value: "}", key: "", font: Measurements.heavyFont))
        return rows
    }
    
    static func getRowsFrom(array: [Any], rootLevel: Int, key: String) -> [JSONRow]  {
        let subLevel = rootLevel + 1
        var rows: [JSONRow] = []
        for (index, object) in array.enumerated() {
            if index == 0 {
                rows.append(JSONRow(color: Measurements.arrayColor, level: rootLevel, value: "[", key: key, font: Measurements.heavyFont))
            }
            let value = ModelValue(key: key, value: object)
            switch value.type {
            case .string:
                rows.append(JSONRow(color: Measurements.stringColor, level: subLevel, value: "\"\(value.value as! String)\"", key: ""))
            case .double:
                rows.append(JSONRow(color: Measurements.doubleColor, level: subLevel, value: "\(value.value ?? 0.0)", key: ""))
            case .bool:
                let v = value.value as? Bool
                let vString = v == true ? "true" : "false"
                rows.append(JSONRow(color: Measurements.boolColor, level: subLevel, value: "\(vString)", key: ""))
            case .int:
                rows.append(JSONRow(color: Measurements.intColor, level: subLevel, value: "\(value.value ?? 0)", key: ""))
            case .array:
                rows.append(contentsOf: JSONRow.getRowsFrom(array: value.value as? [Any] ?? [], rootLevel: subLevel, key: value.key))
            case .dictionary:
                rows.append(contentsOf: JSONRow.getRowsFromDictionary(dictionary: value.value as? Dictionary<String, Any> ?? Dictionary<String, Any>.init(),
                                                                      rootLevel: subLevel,
                                                                      rootKey: value.key,
                                                                      fromArray: true))
            case .null:
                rows.append(JSONRow(color: Measurements.nilColor, level: subLevel, value: "null", key: value.key))
            default:
                print("Can't handle this situation")
            }
            if index == array.count - 1 {
                rows.append(JSONRow(color: Measurements.arrayColor, level: rootLevel, value: "]", key: "", font: Measurements.heavyFont))
            }
        }
        return rows
    }
}
