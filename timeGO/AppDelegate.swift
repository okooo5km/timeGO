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
    
    let statusItem = NSStatusBar.system.statusItem(withLength: 22.0)
    let indicator = NSProgressIndicator()

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
        indicator.minValue = 0.0
        indicator.maxValue = 1.0
        indicator.doubleValue = 0.0
        indicator.autoresizesSubviews = true
        indicator.isIndeterminate = false
        indicator.isDisplayedWhenStopped = true
        indicator.controlSize = NSControl.ControlSize.small
        indicator.style = NSProgressIndicator.Style.spinning
        indicator.frame = NSRect(x: 3, y: 3, width: 16, height: 16)
        
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            button.action = #selector(togglePopoverView)
        }
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopoverView(event!)
            }
        }
        let vc = popover.contentViewController as! TimeGOViewController
        vc.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: StatusItemUpdateDelegate {
    
    func timerDidStop() {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            indicator.removeFromSuperview()
        }
    }
    
    func timerDidStart() {
        if let button = statusItem.button {
            button.image = nil
            button.addSubview(indicator)
        }
    }
    
    func timerUpdate(percent: Double) {
        indicator.doubleValue = percent
    }
    
}

