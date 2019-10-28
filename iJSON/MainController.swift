//
//  MainController.swift
//  iJSON
//
//  Created by 苏威曼 on 2019/10/17.
//  Copyright © 2019 S.M. Technology. All rights reserved.
//

import Cocoa
import SwiftyJSON
import FilesProvider

//TODO: - Display Formating JSON text to the table view with lines


//The Main View Controller
class MainController: NSViewController {
    
    //MARK: - <====== property ======>
    
    //data model
    var model: JSONModel?
    //Inputed json text cover to Dictionary
    var dicnaryObject: Dictionary<String, Any>?
    //Store file path equel to `~/Downloads`
    let downloadsPath: String = "/Users/roots/Downloads"
    //if the input json text are vaild formate it is `true`
    var iSSourceJsonTextVaild: Bool = false
    
    //MARK: - <====== IB Outlet ======>
    
    //Line of Rows
    var numberOfLine: Int = 0
    
    //lineClipView
    @IBOutlet weak var lineClipView: NSClipView!
    
    //Table View to display json formated text
    @IBOutlet weak var lineTableView: NSTableView!
    
    //source text filed
    @IBOutlet var textField: NSTextView!
    
    //For Input file name
    @IBOutlet weak var rootNameTextField: NSTextField!
    
    
    //MARK: - <====== Life cycle<##> ======>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        prepareForTableView()
        prepareForTextField()
    }
    
    //MARK: - <====== Preparing things<##> ======>
    func prepareForTableView() {
        numberOfLine = 2;
        lineTableView.dataSource = self
        lineTableView.delegate = self
        lineTableView.reloadData()
    }
    
    func prepareForTextField() {
        
        textField.font = NSFont(name: "Menlo", size: 12)
        textField.textColor = .systemYellow
        textField.delegate = self
        
    }
    
    
    //MARK: - <===== IB Action =====>
    
    //Start Button Action
    @IBAction func startButtonAction(_ sender: NSButton) {
        
        if !iSSourceJsonTextVaild {
            showWrongSourceJsonTextErrorWhenGenaratingModelFile()
            return
        }
        
        if rootNameTextField.stringValue == "" || rootNameTextField == nil {
            showInputNameTextNilError()
            return
        }
        
        print("rootNameTextField.stringValue:", rootNameTextField.stringValue)
        genarateFile(fileName: rootNameTextField.stringValue)
        
    }
    
    //genarate file to `~/Downloads` folder
    private func genarateFile(fileName: String) {
        
        guard let d = dicnaryObject else {return}
        
        let jsonModel = JSONModel(dictionary: d, name: fileName, key: fileName, level: 0)
        let modelText = jsonModel.createModelString()
        
        let createFilePath = "\(downloadsPath)/\(jsonModel.fileName)"
        let done = FileManager.default.createFile(atPath: createFilePath, contents: modelText.data(using: .utf8), attributes: nil)
        
        if done {
            NSWorkspace.shared.openFile(downloadsPath)
        }else{
            showGenarateFileError()
        }
        
    }
    
    
}

//MARK: - <===== NS Table View Data Source & NSTable View Delegate =====>


extension MainController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
        let label: NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
        label.stringValue = "\(row + 1)"
        label.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        label.isBordered = false
        label.backgroundColor = NSColor.textBackgroundColor
        label.alignment = .center
        view.addSubview(label)
        return view
    }
    
}


//MARK: - <====== NS Text View Delegate ======>

extension MainController: NSTextViewDelegate {
    
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        //User hit Enter Key
        if commandSelector == #selector(insertNewline(_:)) {
            textDidEnter()
            return true
        }
        
        return false
    }
    
    //handle user enter json text
    private func textDidEnter() {
        
        //Check Formate
        checkJSONTextIsVaildFormate()
        //Reload Table View
        lineTableView.reloadData()
        
    }
    
    //check json text is vaild formate
    private func checkJSONTextIsVaildFormate() {
        
        //text
        let text = textField.string
        guard let data: Data = text.data(using: .utf8) else {return}
        
        do {
            
            //JSONSerialization
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            
            //Init JSONModel with dictinary
            if let d = jsonObject as? Dictionary<String, Any> {
                let fileName = self.rootNameTextField.stringValue == "" ? "ROOT" : self.rootNameTextField.stringValue
                model = JSONModel(dictionary: d, name: fileName, key: fileName, level: 0)
                dicnaryObject = d
                iSSourceJsonTextVaild = true
                textField.textColor = .systemGreen
            }else{
                textField.textColor = .systemRed
                showJsonIsNotDcitionaryError()
            }
            
        }catch let e {
            textField.textColor = .systemRed
            showWrongJsonTextError(error: e)
        }
        
    }
    
}


//MARK: - <===== Show Errors =====>

extension MainController {
    
    //if input text is not a vaild json formate
    fileprivate func showWrongJsonTextError(error: Error) {
        let alert = NSAlert()
        alert.messageText = "Wrong JSON Text!"
        alert.informativeText = error.localizedDescription
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    //if genarating model file & JSON text are not pass formate check.
    fileprivate func showWrongSourceJsonTextErrorWhenGenaratingModelFile() {
        let alert = NSAlert()
        alert.messageText = "Your JSON text are invaild!"
        alert.informativeText = "Pleace check your JSON text and press (Enter key) before genarate model file."
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    //if genarate file faild
    fileprivate func showGenarateFileError() {
        let alert = NSAlert()
        alert.messageText = "Can' t not save file to Downloads folder!"
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    //if input json text is not an object value
    fileprivate func showJsonIsNotDcitionaryError() {
        let alert = NSAlert()
        alert.messageText = "Your JSON is Not Dictionary!"
        alert.informativeText = "We only support `Dictionary` Type this version."
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    //If name input text is nil or equel ""
    fileprivate func showInputNameTextNilError() {
        let alert = NSAlert()
        alert.messageText = "Input your root object name"
        alert.informativeText = "A root object name is request for genarator naming system."
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
}
