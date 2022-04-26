//
//   Copyright © 2022 S.M. Technology Ltd. All rights reserved.
//


import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selectedLines = getSeletedLines(from: invocation) as? [String],
              selectedLines.count > 0 else { completionHandler(nil)
            return
        }
        var jsonString: String = ""
        for line in selectedLines {
            jsonString.append(line)
        }
        print(jsonString)
        completionHandler(nil)
    }
    
    private func getSeletedLines(from invocation: XCSourceEditorCommandInvocation)  -> [Any] {
        guard let firstSelectedObject: XCSourceTextRange = invocation.buffer.selections.firstObject as? XCSourceTextRange else { return [] }
        let start = firstSelectedObject.start.line
        let end = min(firstSelectedObject.end.line, invocation.buffer.lines.count - 1)
        return invocation.buffer.lines.subarray(with: NSRange(start...end))
    }
    
}
