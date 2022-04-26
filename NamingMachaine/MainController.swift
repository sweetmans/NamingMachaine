//
//   Copyright © 2022 S.M. Technology Ltd. All rights reserved.
//

import Cocoa
import SwiftyJSON
import FilesProvider
import EasyPeasy
import NamingSystem

//TODO: - Display Formating JSON text to the table view with lines
class MainController: NSViewController {
    var downloadsPath: String = ""
    struct Measurements {
        static let tableViewRowHeight: CGFloat = 20.0
    }
    
    var model: JSONModel?
    var dicnaryObject: Dictionary<String, Any>?
    var iSSourceJsonTextVaild: Bool = false
    var rows: [JSONRow] = []
    
    @IBOutlet weak var lineClipView: NSClipView!
    @IBOutlet weak var lineTableView: NSTableView!
    @IBOutlet var textField: PasteTextView!
    @IBOutlet weak var rootNameTextField: NSTextField!
    @IBOutlet weak var decoderPopIpButtonCell: NSPopUpButtonCell!
    
    @IBOutlet weak var storeFolderLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadsPath = "/Users/\(NSUserName())/Downloads"
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
        textField.pasteDelegate = self
        storeFolderLabel.stringValue = downloadsPath.dropFirst().replacingOccurrences(of: "/", with: " > ")
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
        var modelText: String
        if let tag = decoderPopIpButtonCell.selectedItem?.tag, let type = DecoderType(rawValue: tag) {
            modelText = jsonModel.createModelString(type: type)
        }else {
            modelText = jsonModel.createModelString(type: .swiftDecoder)
        }
        let createFilePath = "\(downloadsPath)/\(jsonModel.fileName)"
        let done = FileManager.default.createFile(atPath: createFilePath, contents: modelText.data(using: .utf8), attributes: nil)
        if done {
            NSWorkspace.shared.open(URL(fileURLWithPath: createFilePath))
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: downloadsPath)
        }else{
            showGenarateFileError()
        }
    }
    
    @IBAction func chooseFolder(_ sender: FlatButton) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose folder to store your swift model file."
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            guard let result = dialog.url?.path else { return }
            downloadsPath = result
            let path = result.dropFirst().replacingOccurrences(of: "/", with: " > ")
            storeFolderLabel.stringValue = path
            print(result)
        } else {
            
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
            keyLabel.backgroundColor = NSColor.clear
            keyLabel.font = rows[row].font
            keyLabel.isBordered = false
            keyLabel.textColor = JSONRow.Measurements.keyColor
            keyLabel.alignment = .left
            let caculateString: NSString = NSString(string: keyValue)
            let width = caculateString.boundingRect(with: NSSize(width: 300, height: Measurements.tableViewRowHeight), options: NSString.DrawingOptions.usesFontLeading, attributes: [NSAttributedString.Key.font: rows[row].font]).width + 5
            view.addSubview(keyLabel)
            let keyLabelLeading: CGFloat = CGFloat(rows[row].level) * leadingMargin
            keyLabel <- [Width(width), Leading(keyLabelLeading), Height(Measurements.tableViewRowHeight), Top(0)]
            let valueLabel: NSTextField = NSTextField()
            valueLabel.backgroundColor = NSColor.clear
            valueLabel.stringValue =  "\(rows[row].value)"
            valueLabel.font = rows[row].font
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
            label.font = rows[row].font
            label.isBordered = false
            label.backgroundColor = NSColor.clear
            label.alignment = .left
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
            rows = JSONRow.getAllRows(From: jsonObject)
            if  let object = jsonObject as? Dictionary<String, Any> {
                handleDictionaryObject(From: object)
            } else if let array = jsonObject as? [Any] {
                handleArrayObject(From: array)
            } else {
                textField.textColor = .systemRed
                showJsonIsNotDcitionaryError()
            }
        } catch let e {
            textField.textColor = .systemRed
            showWrongJsonTextError(error: e)
        }
    }
    
    private func handleDictionaryObject(From dictionary: Dictionary<String, Any>) {
        let fileName = self.rootNameTextField.stringValue == "" ? "ROOT" : self.rootNameTextField.stringValue
        model = JSONModel(dictionary: dictionary, name: fileName, key: fileName, level: 0)
        dicnaryObject = dictionary
        iSSourceJsonTextVaild = true
        textField.textColor = .systemGreen
    }
    
    private func handleArrayObject(From object: [Any]) {
        if let firstObject = object.first {
            if  let object = firstObject as? Dictionary<String, Any> {
                handleDictionaryObject(From: object)
            }
            if let array = firstObject as? [Any] {
                handleArrayObject(From: array)
            }
        } else {
            textField.textColor = .systemRed
            showArrayEmptyError()
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
    
    fileprivate func showArrayEmptyError() {
        let alert = NSAlert()
        alert.messageText = "You are entering empty Array!"
        alert.informativeText = "A object as an <Array> must not empty."
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
}

extension MainController: PasteTextViewDelegate {
    func didPasteText(text: String) {
        let trimmed = text.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        textField.string = trimmed
        textDidEnter()
    }
}
