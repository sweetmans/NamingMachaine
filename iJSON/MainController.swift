//
//  Copyright © 2021 S.M. Technology. All rights reserved.
//

import Cocoa
import SwiftyJSON
import FilesProvider
import EasyPeasy

//TODO: - Display Formating JSON text to the table view with lines
class MainController: NSViewController {
    struct Measurements {
        static var downloadsPath: String { return  "/Users/\(NSUserName())/Downloads" }
        static let tableViewRowHeight: CGFloat = 14.0
    }
    
    var model: JSONModel?
    var dicnaryObject: Dictionary<String, Any>?
    var iSSourceJsonTextVaild: Bool = false
    var rows: [JSONRow] = []
    
    @IBOutlet weak var lineClipView: NSClipView!
    @IBOutlet weak var lineTableView: NSTableView!
    @IBOutlet var textField: NSTextView!
    @IBOutlet weak var rootNameTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForTableView()
        prepareForTextField()
    }
    
    func prepareForTableView() {
        lineTableView.dataSource = self
        lineTableView.delegate = self
        lineTableView.reloadData()
    }
    
    func prepareForTextField() {
        textField.font = NSFont(name: "Menlo", size: 12)
        textField.textColor = .systemYellow
        textField.delegate = self
        
    }
    
    @IBAction func startButtonAction(_ sender: NSButton) {
        if !iSSourceJsonTextVaild {
            showWrongSourceJsonTextErrorWhenGenaratingModelFile()
            return
        }
        if rootNameTextField.stringValue == "" || rootNameTextField == nil {
            showInputNameTextNilError()
            return
        }
        genarateFile(fileName: rootNameTextField.stringValue)
    }
    
    private func showFileGenerateController() {
        let mvc = FileGenerateController(windowNibName: "FileGenerateController")
        if let window = mvc.window {
            NSApp.mainWindow?.beginCriticalSheet(window, completionHandler: { (resp) in
                
            })
        }
    }
    
    private func genarateFile(fileName: String) {
        guard let d = dicnaryObject else {return}
        let jsonModel = JSONModel(dictionary: d, name: fileName, key: fileName, level: 0)
        let modelText = jsonModel.createModelString()
        let createFilePath = "\(Measurements.downloadsPath)/\(jsonModel.fileName)"
        let done = FileManager.default.createFile(atPath: createFilePath, contents: modelText.data(using: .utf8), attributes: nil)
        if done {
            NSWorkspace.shared.open(URL(fileURLWithPath: createFilePath))
        }else{
            showGenarateFileError()
        }
    }
}

extension MainController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count;
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return Measurements.tableViewRowHeight
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let identifier = tableColumn?.identifier.rawValue,
           identifier == "content" {
            let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: tableColumn?.width ?? 0, height: Measurements.tableViewRowHeight))
            let leadingMargin: CGFloat = 30.0
            let keyLabel: NSTextField = NSTextField()
            let keyValue: String = rows[row].key == "" ? "" : "\"\(rows[row].key)\" :"
            keyLabel.stringValue =  keyValue
            keyLabel.font = NSFont.systemFont(ofSize: 12, weight: .bold)
            keyLabel.isBordered = false
            keyLabel.textColor = JSONRow.keyColor
            keyLabel.alignment = .left
            let caculateString: NSString = NSString(string: keyValue)
            let width = caculateString.boundingRect(with: NSSize(width: 300, height: Measurements.tableViewRowHeight), options: NSString.DrawingOptions.usesFontLeading, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12, weight: .bold)]).width + 5
            view.addSubview(keyLabel)
            let keyLabelLeading: CGFloat = CGFloat(rows[row].level) * leadingMargin
            keyLabel <- [Width(width), Leading(keyLabelLeading), Height(14), Top(0)]
                            let valueLabel: NSTextField = NSTextField()
                            valueLabel.stringValue =  "\(rows[row].value)"
                            valueLabel.font = NSFont.systemFont(ofSize: 12, weight: .bold)
                            valueLabel.isBordered = false
                            valueLabel.textColor = rows[row].color
                            valueLabel.alignment = .left
                            view.addSubview(valueLabel)
                            let valueLabelLeading: CGFloat = CGFloat(rows[row].level) * leadingMargin + width
                            valueLabel <- [Trailing(0), Leading(valueLabelLeading), Height(Measurements.tableViewRowHeight), Top(0)]
                                            return view
        }else{
            let view: NSView = NSView(frame: NSRect(x: 0, y: 0, width: tableColumn?.width ?? 0, height: Measurements.tableViewRowHeight))
            let label: NSTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: tableColumn?.width ?? 0, height: Measurements.tableViewRowHeight))
            label.stringValue = "\(row + 1)"
            label.font = NSFont.systemFont(ofSize: 12, weight: .bold)
            label.isBordered = false
            label.backgroundColor = NSColor.clear
            label.alignment = .center
            view.addSubview(label)
            return view
        }
    }
}

extension MainController: NSTextViewDelegate {
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
            textDidEnter()
            return true
        }
        return false
    }
    
    private func textDidEnter() {
        checkJSONTextIsVaildFormate()
        lineTableView.reloadData()
    }
    
    private func checkJSONTextIsVaildFormate() {
        let text = textField.string
        guard let data: Data = text.data(using: .utf8) else {return}
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let d = jsonObject as? Dictionary<String, Any> {
                let fileName = self.rootNameTextField.stringValue == "" ? "ROOT" : self.rootNameTextField.stringValue
                model = JSONModel(dictionary: d, name: fileName, key: fileName, level: 0)
                dicnaryObject = d
                iSSourceJsonTextVaild = true
                textField.textColor = .systemGreen
                rows = JSONRow.getRowsFrom(dictionary: d, rootLevel: 0, rootKey: "")
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

extension MainController {
    fileprivate func showWrongJsonTextError(error: Error) {
        let alert = NSAlert()
        alert.messageText = "Wrong JSON Text!"
        alert.informativeText = error.localizedDescription
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    fileprivate func showWrongSourceJsonTextErrorWhenGenaratingModelFile() {
        let alert = NSAlert()
        alert.messageText = "Your JSON text are invaild!"
        alert.informativeText = "Pleace check your JSON text and press (Enter key) before genarate model file."
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    fileprivate func showGenarateFileError() {
        let alert = NSAlert()
        alert.messageText = "Can' t not save file to Downloads folder!"
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    fileprivate func showJsonIsNotDcitionaryError() {
        let alert = NSAlert()
        alert.messageText = "Your JSON is Not Dictionary!"
        alert.informativeText = "We only support `Dictionary` Type this version."
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    fileprivate func showInputNameTextNilError() {
        let alert = NSAlert()
        alert.messageText = "Input your root object name"
        alert.informativeText = "A root object name is request for genarator naming system."
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
}
