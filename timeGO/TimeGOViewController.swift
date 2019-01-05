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
    
    @IBOutlet var firstView: NSView!
    @IBOutlet var secondView: NSView!

    @IBOutlet weak var timeSelector: NSPopUpButton!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var pauseButton: NSButton!
    
    @IBAction func quitApp(_ sender: Any) {
        if timer.isValid {
            timer.invalidate()
        }
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func startTimer(_ sender: Any) {
        timeToCount = getIntFromString(str: timeSelector.selectedItem?.title ?? "0 分钟") * 60
        timeLabel.stringValue = "\(timeToCount / 60)'\(timeToCount % 60)\""
        if timeToCount > 0 {
            self.view = secondView
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountHandler), userInfo: nil, repeats: true)
            pauseButton.title = "暂停"
        } else {
            alertTimeZero()
        }
    }
    
    func alertTimeZero() {
        let alert = NSAlert()
        alert.messageText = "提醒"
        alert.informativeText = "定时时间不能选 0 分钟"
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
    
    @IBAction func pauseTimer(_ sender: Any) {
        if pauseButton.title == "暂停" {
            timer.invalidate()
            pauseButton.title = "继续"
        } else {
            if timeToCount > 0 {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountHandler), userInfo: nil, repeats: true)
            } else {
                alertTimeZero()
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @objc func timerCountHandler(_ sender: Any) {
        if timeToCount > 0 {
            timeToCount -= 1
            timeLabel.stringValue = "\(timeToCount / 60)'\(timeToCount % 60)\""
            return
        }
        notificationFly()
        stopTimer(self)
    }
    
    func notificationFly() {
        // 定义NSUserNotification
        let userNotification = NSUserNotification()
        userNotification.title = "timeGO"
        userNotification.subtitle = timeSelector.selectedItem?.title
        userNotification.informativeText = "倒计时已结束!"
        // 使用NSUserNotificationCenter发送NSUserNotification
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
    
    /// 从字符串中提取数字
    func getIntFromString(str: String) -> Int {
        let scanner = Scanner(string: str)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        var number :Int = 0
        scanner.scanInt(&number)
        return number
    }
    
}
