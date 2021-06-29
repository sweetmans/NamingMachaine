//
//  Copyright © 2021 S.M. Technology. All rights reserved.
//

import Cocoa



//MARK: - <====== Model Value ======>
struct ModelValue {
    enum ValueType: String {
        case bool = "Bool"
        case string = "String"
        case int = "Int"
        case double = "Double"
        case null = "NULL"
        case dictionary = "{}"
        case array = "[]"
        case unknow = "Unknow"
    }
    
    var key: String
    var value: Any?
    var type: ValueType
    
    init(key: String, value: Any?) {
        self.key = key
        self.value = value
        self.type = ModelValue.getTypeFrom(value: value)
    }
    
    static func getTypeFrom(value: Any?) -> ValueType {
        if value == nil { return .null }
        switch value {
        case let number as NSNumber:
            if (number.isBool) { return .bool }
            if ("\(String(describing: value))".contains(".")) { return .double }
            return .int
        case _ as String:
            return .string
        case _ as NSNull:
            return .null
        case nil:
            return .null
        case _ as [Any]:
            return .array
        case _ as [String: Any]:
            return .dictionary
        default:
            return .unknow
        }
    }
    
    mutating func changeValue (newValue: Any) {
        value = newValue
    }
}

private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(cString: trueNumber.objCType)
private let falseObjCType = String(cString: falseNumber.objCType)

extension NSNumber {
    fileprivate var isBool: Bool {
        let objCType = String(cString: self.objCType)
        if (self.compare(trueNumber) == .orderedSame && objCType == trueObjCType) || (self.compare(falseNumber) == .orderedSame && objCType == falseObjCType) {
            return true
        } else {
            return false
        }
    }
}

extension String {
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    var nameFromat: String {
        return self.removeAllSapce.capitalized
    }
}
