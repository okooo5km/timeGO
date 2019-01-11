//
//  TimeGOViewController.swift
//  timeGO
//
//  Created by 5km on 2019/1/5.
//  Copyright © 2019 5km. All rights reserved.
//
import Cocoa
import AVFoundation

class TimeGOViewController: NSViewController {
    
    var timer: Timer!
    var timeToCount: Int = 0
    var timeToEnd: Int = 0
    
    var delegate: StatusItemUpdateDelegate!
    
    @IBOutlet var firstView: NSView!
    @IBOutlet var secondView: NSView!
    @IBOutlet var settingsPopover: NSPopover!
    
    @IBOutlet weak var tipLabel: NSTextField!
    @IBOutlet weak var timeSelector: NSPopUpButton!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        settingsPopover.delegate = self
        timeArray = getTimeArray()
        timeSelector.removeAllItems()
        for timeItem in timeArray {
            var timeValue = "\(timeItem["time", default: "0"]) 分钟"
            let timeTip = timeItem["tip", default: "时间到了！"]
            while timeSelector.itemTitles.contains(timeValue) {
                timeValue.append("\'")
            }
            timeSelector.addItem(withTitle: timeValue)
            timeSelector.item(withTitle: timeValue)?.toolTip = timeTip
        }
        timeSelector.selectItem(at: 0)
        popUpSelectionDidChange(timeSelector)
    }
    
    @IBAction func popUpSelectionDidChange(_ sender: NSPopUpButton) {
        tipLabel.stringValue = "通知内容: " + (timeSelector.selectedItem?.toolTip)!
    }
    
    @IBAction func startTimer(_ sender: Any) {
        timeToCount = getIntFromString(str: timeSelector.selectedItem?.title ?? "0 分钟") * 60
        timeToEnd = getIntFromString(str: timeSelector.selectedItem?.title ?? "0 分钟") * 60
        timeLabel.stringValue = "\(timeToCount / 60)'\(timeToCount % 60)\""
        if timeToCount > 0 {
            self.view = secondView
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountHandler), userInfo: nil, repeats: true)
            pauseButton.title = "暂停"
            if delegate != nil {
                delegate.timerDidStart()
            }
        } else {
            tipInfo(withTitle: "提醒", withMessage: "定时时间不能选 0 分钟")
        }
    }
    
    @IBAction func pauseTimer(_ sender: Any) {
        if pauseButton.title == "暂停" {
            timer.invalidate()
            pauseButton.title = "继续"
        } else {
            if timeToCount > 0 {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountHandler), userInfo: nil, repeats: true)
            } else {
                tipInfo(withTitle: "提醒", withMessage: "定时时间不能选 0 分钟")
                self.view = firstView
            }
            pauseButton.title = "暂停"
        }
    }
    
    @IBAction func stopTimer(_ sender: Any) {
        if timer.isValid {
            timer.invalidate()
        }
        self.view = firstView
        if delegate != nil {
            delegate.timerDidStop()
        }
    }
    
    @objc func timerCountHandler(_ sender: Any) {
        if timeToCount > 0 {
            timeToCount -= 1
            timeLabel.stringValue = "\(timeToCount / 60)'\(timeToCount % 60)\""
            if delegate != nil {
                let percent = 1.0 - Double(timeToCount) / Double(timeToEnd)
                delegate.timerUpdate(percent: percent)
            }
            return
        }
        notificationFly()
        stopTimer(self)
    }
    
    @IBAction func toggleSettingsView(_ sender: AnyObject) {
        if settingsPopover.isShown {
            settingsPopover.performClose(sender)
        } else {
            settingsPopover.show(relativeTo: settingsButton.bounds, of: settingsButton, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func notificationFly() {
        let userNotification = NSUserNotification()
        userNotification.title = "timeGO"
        userNotification.subtitle = timeSelector.selectedItem?.title
        userNotification.informativeText = (timeSelector.selectedItem?.toolTip)!
        let userNotificationCenter = NSUserNotificationCenter.default
        userNotificationCenter.delegate = self as? NSUserNotificationCenterDelegate
        userNotificationCenter.scheduleNotification(userNotification)
        let soundURL = Bundle.main.url(forResource: "alert-sound", withExtension: "caf")
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL! as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}

extension TimeGOViewController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        if arrayChanged {
            timeSelector.removeAllItems()
            if timeArray.count > 0 {
                for timeItem in timeArray {
                    var timeValue = "\(timeItem["time", default: "0"]) 分钟"
                    let timeTip = timeItem["tip", default: "时间到了！"]
                    while timeSelector.itemTitles.contains(timeValue) {
                        timeValue.append("\'")
                    }
                    timeSelector.addItem(withTitle: timeValue)
                    timeSelector.item(withTitle: timeValue)?.toolTip = timeTip
                }
                timeSelector.selectItem(at: 0)
                tipLabel.stringValue = "通知内容: " + timeArray[0]["tip"]!
            }
            UserDefaults.standard.set(timeArray, forKey: timeDataKey)
            arrayChanged = false
        }
    }
}
