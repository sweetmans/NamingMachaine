//
//   Copyright © 2022 S.M. Technology Ltd. All rights reserved.
//

import Cocoa

public struct JSONRow {
    public struct Measurements {
        public static let heavyFont = NSFont(name: "Menlo Bold Italic", size: 14) ?? NSFont.systemFont(ofSize: 14)
        public static var stringColor: NSColor { return .systemRed }
        public static var doubleColor: NSColor { return .systemPurple }
        public static var intColor: NSColor { return .systemPurple }
        public static var boolColor: NSColor { return .systemPink }
        public static var nilColor: NSColor { return .systemPink }
        public static var defaultColor: NSColor { return .systemPurple }
        public static var keyColor: NSColor { return .systemGreen }
        public static var arrayColor: NSColor { return .systemOrange}
    }
    
    public var color: NSColor
    public var level: Int
    public var value: String
    public var key: String
    public var font: NSFont = NSFont(name: "Menlo Bold", size: 13) ?? NSFont.systemFont(ofSize: 13)
    
    public static func getAllRows(From object: Any) -> [JSONRow] {
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
    
    public static func getRowsFromDictionary(dictionary: Dictionary<String, Any>,
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
        let sortedDictionary = dictionary.sorted { $0.key.lowercased() < $1.key.lowercased() }
        for object in sortedDictionary {
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
    
    public static func getRowsFrom(array: [Any], rootLevel: Int, key: String) -> [JSONRow]  {
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
