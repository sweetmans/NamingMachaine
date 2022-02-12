//
//  Copyright © 2021年 S.M. Technlogy, Ltd. All rights reserved.
//

import Foundation
import XcodeKit
import AppKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let lines = invocation.buffer.selections
        lines.removeAllObjects()
        lines.addObjects(from: ["123456"])
        completionHandler(nil)
        print("JSON:", lines)
    }
}
