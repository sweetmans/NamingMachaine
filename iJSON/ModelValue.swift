//
//  ModelValue.swift
//  iJSON
//
//  Created by 苏威曼 on 2019/10/28.
//  Copyright © 2019 S.M. Technology. All rights reserved.
//

import Cocoa



//MARK: - <====== Model Value ======>

struct ModelValue {
    
    //Value Type
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
    
    //Key of value
    var key: String
    //Value of key
    var value: Any?
    //Value type
    var type: ValueType
    

    //init
    init(key: String, value: Any?) {
        self.key = key
        self.value = value
        self.type = ModelValue.getTypeFrom(value: value)
    }
    
    //get value from type
    static func getTypeFrom(value: Any?) -> ValueType {
        
        if value == nil {
            return .null
        }
        
        switch value {
            
        case let number as NSNumber:
            if (number.isBool) {
                return .bool
            }
            if ("\(String(describing: value))".contains(".")) {
                return .double
            }
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
    
    //mutating value.
    mutating func changeValue (newValue: Any) {
        value = newValue
    }
    
}


//MARK: - <====== Number Extension IsBool ======>

private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(cString: trueNumber.objCType)
private let falseObjCType = String(cString: falseNumber.objCType)

//MARK: - <====== NSNumber Extension ======>

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

//MARK: - <====== String Extension ======>

extension String {
    
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    var nameFromat: String {
        return self.removeAllSapce.capitalized
    }
    
}
