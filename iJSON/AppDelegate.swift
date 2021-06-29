//
//  Copyright © 2021 S.M. Technology. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    let rootViewController: MainController = MainController(nibName: "MainController", bundle: nil)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.window.delegate = self
        self.window.makeMain()
        self.window.makeKey()
        self.window.contentView?.addSubview(rootViewController.view)
        rootViewController.view.frame = self.window.contentView?.bounds ?? NSRect.zero
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        var newSize: NSSize = frameSize
        if (frameSize.width < 800) { newSize.width = 800 }
        if (frameSize.height < 600) { newSize.height = 600 }
        self.rootViewController.view.frame = NSRect(origin: NSPoint(x: 0, y: -20), size: newSize)
        return newSize
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }
}

extension CGFloat {
    static var screenCenterX: CGFloat {
        return (NSScreen.main?.frame.width ?? 0) / 2
    }
    
    static var screenCenterY: CGFloat {
        (NSScreen.main?.frame.height ?? 0) / 2
    }
}

extension NSPoint {
    static var screenCenter: NSPoint {
        return NSPoint(x: CGFloat.screenCenterX, y: CGFloat.screenCenterX)
    }
}

extension NSRect {
    static func screenCenterOrigin(size: NSSize) -> NSRect {
        return NSRect(x: CGFloat.screenCenterX - size.width / 2, y: CGFloat.screenCenterY - size.height / 2, width: size.width, height: size.height)
    }
}
