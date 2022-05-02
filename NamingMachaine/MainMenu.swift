//
//   Copyright © 2022 S.M. Technology Ltd. All rights reserved.
//

import Foundation
import AppKit
import NamingSystem
import UniformTypeIdentifiers

class MainMenu: NSMenu {
    @IBAction func saveDocument(sender: NSMenuItem) {
        JSONProvider.shared.showSavePanel()
    }
}
