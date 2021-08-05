//
//  Copyright © 2021 S.M. Technology. All rights reserved.
//

import Foundation
import AppKit

protocol PasteTextViewDelegate: NSObjectProtocol {
    func didPasteText(text: String)
}

class PasteTextView: NSTextView {
    weak var pasteDelegate: PasteTextViewDelegate?
    
    override func paste(_ sender: Any?) {
        guard let string = NSPasteboard.general.string(forType: .string) else { return }
        pasteDelegate?.didPasteText(text: string)
    }
}
