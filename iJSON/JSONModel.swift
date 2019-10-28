//
//  JSONModel.swift
//  iJSON
//
//  Created by 苏威曼 on 2019/10/19.
//  Copyright © 2019 S.M. Technology. All rights reserved.
//

import Cocoa


//TODO: FIX value type is `Array` loop Implement issuse



class JSONModel: NSObject {
    
    
    init(dictionary: Dictionary<String, Any>, name: String, key: String, level: Int) {
        
        self.key = key
        self.name = name
        self.level = level
        
        for key in dictionary.keys {
            
            var value: ModelValue = ModelValue(key: key, value: dictionary[key])
            
            if (value.type == .dictionary) {
                let model = JSONModel.init(dictionary: dictionary[key] as! Dictionary<String, Any>, name: "\(name.nameFromat)\(key.nameFromat)", key: key, level: level + 1)
                value.changeValue(newValue: model)
            }
            
            if (value.type == .array) {
                
                guard let ds = value.value as? [Any] else {return}
                var models: [Any] = []
                
                for d in ds {
                    if let dict = d as? Dictionary<String, Any> {
                        let model = JSONModel.init(dictionary: dict, name: "\(name.nameFromat)\(key.nameFromat)", key: key, level: level + 1)
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
    
    //File Name
    var fileName = "DefaultFileName"
    
    //name of object
    var name: String
    //key of object
    var key: String
    
    //Level
    var level:Int = 0
    
    //values
    var values: [String: ModelValue] = [String: ModelValue]()
    
}

//MARK: - <====== JSON MODEL STriNG TEXT<##> ======>

extension JSONModel {
    
    func createModelString() -> String {
        
        var text: String = ""
        
        if (self.level == 0) {
            fileName = "\(name).swift"
            text.append(creatCopyrightString())
        }
        
        //创建结构体        
        return "\(text)\(createStruct(text: text))"
    }
    
    //头部描述文本
    private func creatCopyrightString() -> String {
        
        return "//\n//  \(fileName)\n//  Replace with your project name. \n//\n//  Created by iJSON Model Generator on \(getTimeString()).\n//  Copyright © \(getYearString()) Replace with your organization name. All rights reserved.\n//\n\nimport Foundation\nimport SwiftyJSON\n\n\n"
        
    }
    
    //获取时间
    private func getTimeString() -> String {
        
        let formate: DateFormatter = DateFormatter()
        formate.timeZone = Calendar.current.timeZone
        formate.dateFormat = "yyyy/MM/dd"
        
        return formate.string(from: Date())
    }
    
    //获取年
    private func getYearString() -> String {
        
        let formate: DateFormatter = DateFormatter()
        formate.timeZone = Calendar.current.timeZone
        formate.dateFormat = "yyyy"
        
        return formate.string(from: Date())
    }
    
    
    //创建结构
    private func createStruct(text: String) -> String {
        
        let newText = createStructProperty(text: text)
        var impText = createStructImplementForSwityJSOnN(text: newText)
        
        for value in self.values {
            switch value.value.type {
            case .dictionary:
                if let jm = value.value.value as? JSONModel {
                    impText = "\(impText)\n\n\(jm.createStruct(text: impText))"
                }
            case .array:
                if let jm = value.value.value as? [JSONModel] {
                    if jm.count > 0 {
                        impText = "\(impText)\n\n\(jm[0].createStruct(text: impText))"
                    }
                }
            default:
                print("No need to create struct")
            }
        }
        
        return impText
    }
    
    //创建结构体属性
    private func createStructProperty(text: String) -> String {
        
        var text: String = "//MARK - \(name)\nstruct \(name) {\n\n    //Propertys\n"
        for value in self.values {
            switch value.value.type {
            case .int, .double, .string, .bool:
                text.append("    var \(value.key): \(value.value.type.rawValue)?\n")
            case .dictionary:
                if let jm = value.value.value as? JSONModel {
                    text.append("    var \(value.key): \(jm.name)?\n")
                }
            case .array:
                //content is dictionary
                if let jm = value.value.value as? [JSONModel] {
                    if jm.count > 0 {
                        text.append("    var \(value.key): [\(jm[0].name)] = []\n")
                    }
                }
                
                //content is none dictionary
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
    
    //Create Struct Implement - SwityJSON
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
        return "\(newText)    }\n}\n\n\n"
        
    }
    
}


