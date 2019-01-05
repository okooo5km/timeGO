//
//  AppDelegate.swift
//  timeGO
//
//  Created by 5km on 2019/1/5.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var popover: NSPopover!
    var eventMonitor: EventMonitor?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    @objc func openPopoverView(_ sender: AnyObject) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    @objc func closePopoverView(_ sender: AnyObject) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    @objc func togglePopoverView(_ sender: AnyObject) {
        if popover.isShown {
            closePopoverView(sender)
        } else {
            openPopoverView(sender)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            button.action = #selector(togglePopoverView)
        }
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopoverView(event!)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

