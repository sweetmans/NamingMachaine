//
//  AppDelegate.swift
//  iJSON
//
//  Created by 苏威曼 on 2019/10/17.
//  Copyright © 2019 S.M. Technology. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let rootViewController: MainController = MainController(nibName: "MainController", bundle: nil)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        self.window.delegate = self
        
        self.window.contentView?.addSubview(rootViewController.view)
        rootViewController.view.frame = self.window.contentView?.bounds ?? NSRect.zero
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}



extension AppDelegate: NSWindowDelegate {
    
    //When User or system resize window
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
                
        var newSize: NSSize = frameSize
        
        //ensure width > 800
        if (frameSize.width < 800) {
            newSize.width = 800
        }
        
        //ensure height > 600
        if (frameSize.height < 600) {
            newSize.height = 600
        }
        
        //reset the root view controller view size
        self.rootViewController.view.frame = NSRect(origin: NSPoint(x: 0, y: -20), size: newSize)
        return newSize
        
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
    
    // the mac screen center point
    static var screenCenter: NSPoint {
        return NSPoint(x: CGFloat.screenCenterX, y: CGFloat.screenCenterX)
    }
    
}


extension NSRect {
    
    //the fram of specify size which is layout in screen center
    static func screenCenterOrigin(size: NSSize) -> NSRect {
        return NSRect(x: CGFloat.screenCenterX - size.width / 2, y: CGFloat.screenCenterY - size.height / 2, width: size.width, height: size.height)
    }
}
