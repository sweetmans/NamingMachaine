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
    @IBOutlet weak var decoderPopIpButtonCell: NSPopUpButtonCell!
    
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
        textField.pasteDelegate = self
    }
    
    @IBAction func startButtonAction(_ sender: NSButton) {
        JSONProvider.shared.showSavePanel()
    }
    
    @IBAction func didChangeDecoder(_ sender: NSPopUpButtonCell) {
        guard let tag = decoderPopIpButtonCell.selectedItem?.tag, let type = DecoderType(rawValue: tag) else {
            return
        }
        JSONProvider.shared.setDecoderType(type: type)
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
                ErrorHandler.showJsonIsNotDcitionaryError()
            }
        } catch let error {
            textField.textColor = .systemRed
            ErrorHandler.showWrongJsonTextError(error: error)
        }
    }
    
    private func handleDictionaryObject(From dictionary: Dictionary<String, Any>) {
        model = JSONModel(dictionary: dictionary, name: "ROOT", key: "ROOT", level: 0)
        JSONProvider.shared.setDicnaryObject(object: dictionary)
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
            ErrorHandler.showArrayEmptyError()
        }
    }
}

extension MainController: PasteTextViewDelegate {
    func didPasteText(text: String) {
        let trimmed = text.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        textField.string = trimmed
        textDidEnter()
    }
}
