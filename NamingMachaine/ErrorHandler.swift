//
//   Copyright © 2022 S.M. Technology Ltd. All rights reserved.
//

import Foundation
import AppKit

class ErrorHandler {
    class func showWrongJsonTextError(error: Error) {
        let alert = NSAlert()
        alert.messageText = "Wrong JSON Text"
        alert.informativeText = error.localizedDescription
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    class func showWrongSourceJsonTextErrorWhenGenaratingModelFile() {
        let alert = NSAlert()
        alert.messageText = "Your JSON Text Are invaild"
        alert.informativeText = "Pleace Check Your JSON Text And Press (Enter key) Before Genarate Model File"
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    class func showGenarateFileError() {
        let alert = NSAlert()
        alert.messageText = "Can Not Save File To Downloads Folder"
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    class func showJsonIsNotDcitionaryError() {
        let alert = NSAlert()
        alert.messageText = "Your JSON Is Not Dictionary"
        alert.informativeText = "We Nnly Support `Dictionary` Type This Version."
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    class func showInputNameTextNilError() {
        let alert = NSAlert()
        alert.messageText = "Input Your Root Object Name"
        alert.informativeText = "A Root Object Name Is Request For Genarator Naming System"
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    class func showArrayEmptyError() {
        let alert = NSAlert()
        alert.messageText = "You Are Entering An Empty Array"
        alert.informativeText = "A Object As A <Array> Must Not Empty"
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    class func showEmptyEmptyError() {
        let alert = NSAlert()
        alert.messageText = "Please Enter Your JSON Text"
        alert.informativeText = "You Must Enter JSON Text Before Press CAMMAND + R Or Generate Button"
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
    
    class func showCouldNotGetURLError() {
        let alert = NSAlert()
        alert.messageText = "Could Not Handle Save File Action"
        alert.informativeText = "We Could Not Fetch The File URL From The NSSavePanel"
        alert.icon = NSImage(named: "Error")
        alert.runModal()
    }
}
