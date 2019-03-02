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
        indicator.isIndeterminate = false
        indicator.controlSize = NSControl.ControlSize.small
        indicator.style = NSProgressIndicator.Style.spinning
        indicator.isHidden = true
        
        // 首次运行的特别处理
        let againRun = UserDefaults.standard.bool(forKey: UserDataKeys.again)
        if !againRun {
            var languages = ["zh-Hans", "zh-Hant", "en", "ja", "ko"]
            let lan = Locale.preferredLanguages[0]
            var lanSelected = lan.prefix(upTo: -3)
            if languages.contains(lanSelected) {
                languages[0] = lanSelected
            } else {
                lanSelected = "en"
            }
            UserDefaults.standard.setValue("system", forKey: UserDataKeys.currentLanguage)
            UserDefaults.standard.setValue([lanSelected] + Locale.preferredLanguages, forKey: UserDataKeys.languages)
            UserDefaults.standard.setValue(true, forKey: UserDataKeys.again)
            UserDefaults.standard.synchronize()
        }
        
        // 获取配置中的语言设置
        let languages = UserDefaults.standard.array(forKey: UserDataKeys.languages) as! [String]
        currentLanguage = languages[0]
        Bundle.main.onLanguage()
        
        // 启动时检查更新
        if UserDefaults.standard.bool(forKey: UserDataKeys.checkUpdate) {
            let updater = TimeGoUpdater(user: "smslit") {}
            updater.check()
        }
        
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            button.action = #selector(togglePopoverView)
            indicator.frame = NSRect(x: (button.frame.width - 16) / 2,
                                     y: (button.frame.height - 16) / 2,
                                     width: 16,
                                     height: 16)
            button.addSubview(indicator)
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
        if (tagAppRelaunch) {
            NSWorkspace.shared.launchApplication(withBundleIdentifier: "top.smslit.timeGO", options: [NSWorkspace.LaunchOptions.async,  NSWorkspace.LaunchOptions.newInstance], additionalEventParamDescriptor: nil, launchIdentifier: nil)
        }
    }
}

extension AppDelegate: StatusItemUpdateDelegate {
    
    func timerDidStop() {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
            indicator.isHidden = true
        }
    }
    
    func timerDidStart() {
        if let button = statusItem.button {
            button.image = nil
            indicator.doubleValue = 0.0
            indicator.isHidden = false
        }
    }
    
    func timerUpdate(percent: Double) {
        indicator.doubleValue = percent
    }
    
}

