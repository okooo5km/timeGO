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
    var timerIndexQueue = TimerIndexQueue()
    var timerNow = [String: String]()
    
    var delegate: StatusItemUpdateDelegate!
    
    @IBOutlet var settingsPopover: NSPopover!
    
    @IBOutlet weak var timeSelector: NSPopUpButton!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var quitButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        settingsPopover.delegate = self
        timeArray = getTimeArray()
        updateTimeSelectorFrom(timeArray: timeArray)
    }
    
    func updateTimeSelectorFrom(timeArray: [[String: String]]) {
        timeSelector.removeAllItems()
        if timeArray.count <= 0 {
            return
        }
        for timeItem in timeArray {
            let timeTag = timeItem["tag", default:""]
            var timeValue = timeItem["time", default: "0"]
            if timeValue.isNumeric {
                timeValue = "\(timeItem["time", default: "0"]) 分钟"
            } else {
                let indexArray = timeValue.parseTimerExpression()
                timeValue = ""
                for index in indexArray {
                    let text = timeArray[index]["time"]!
                    timeValue = timeValue + text + "+"
                }
                timeValue.removeLast()
                timeValue += " 分钟"
            }
            let timeTip = timeItem["tip", default: "时间到了！"]
            var itemTitle = (timeTag == "") ? timeValue : "\(timeTag)(\(timeValue))"
            while timeSelector.itemTitles.contains(itemTitle) {
                itemTitle.append("\'")
            }
            timeSelector.addItem(withTitle: itemTitle)
            timeSelector.item(withTitle: itemTitle)?.toolTip = timeTip
        }
        timeSelector.selectItem(at: 0)
    }
    
    @IBAction func startTimer(_ sender: Any) {
        let timeValue = timeArray[timeSelector.indexOfSelectedItem]["time", default: "0"]
        if timeValue.isNumeric {
            timerIndexQueue.enqueue(timeSelector.indexOfSelectedItem)
        } else if timeValue.isTimerExpression {
            let indexArray = timeValue.parseTimerExpression()
            for index in indexArray {
                timerIndexQueue.enqueue(index)
            }
        }
        startSingleTimer()
    }
    
    func startSingleTimer() {
        timerNow = timeArray[timerIndexQueue.dequeue()!]
        let timeValue = timerNow["time", default: "0"]
        timeToCount = timeValue.toInt() * 60
        timeToEnd = timeToCount
        timeLabel.stringValue = "\(timeToCount / 60)'\(timeToCount % 60)\""
        if timeToCount > 0 {
            setNormalContorls(ishidden: true)
            setCountContorls(ishidden: false)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountHandler), userInfo: nil, repeats: true)
            pauseButton.image = NSImage(named: "pauseIcon")
            if delegate != nil {
                delegate.timerDidStart()
            }
        } else {
            tipInfo(withTitle: "提醒", withMessage: "定时时间不能选 0 分钟")
        }
    }
    
    @IBAction func pauseTimer(_ sender: Any) {
        if pauseButton.image?.name() == "pauseIcon" {
            timer.invalidate()
            pauseButton.image = NSImage(named: "startIcon")
        } else {
            if timeToCount > 0 {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountHandler), userInfo: nil, repeats: true)
            } else {
                tipInfo(withTitle: "提醒", withMessage: "定时时间不能选 0 分钟")
                setCountContorls(ishidden: true)
                setNormalContorls(ishidden: false)
            }
            pauseButton.image = NSImage(named: "pauseIcon")
        }
    }
    
    @IBAction func stopTimer(_ sender: Any) {
        while timerIndexQueue.count > 0 {
            timerIndexQueue.dequeue()
        }
        stopSingleTimer()
    }
    
    func stopSingleTimer() {
        if timer.isValid {
            timer.invalidate()
        }
        setCountContorls(ishidden: true)
        setNormalContorls(ishidden: false)
        if delegate != nil {
            delegate.timerDidStop()
        }
        if timerIndexQueue.count > 0 {
            startSingleTimer()
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
        stopSingleTimer()
    }
    
    @IBAction func toggleSettingsView(_ sender: AnyObject) {
        if settingsPopover.isShown {
            settingsPopover.performClose(sender)
        } else {
            settingsPopover.show(relativeTo: settingsButton.bounds, of: settingsButton, preferredEdge: NSRectEdge.minY)
        }
    }
    
    @IBAction func quitApp(_ sender: Any) {
        if arrayChanged {
            UserDefaults.standard.set(timeArray, forKey: UserDataKeys.time)
        }
        NSApplication.shared.terminate(true)
    }
    
    func notificationFly() {
        let userNotification = NSUserNotification()
        userNotification.title = "timeGO"
        userNotification.subtitle = timerNow["time"]! + "分钟"
        userNotification.informativeText = timerNow["tip"]!
        let userNotificationCenter = NSUserNotificationCenter.default
        userNotificationCenter.delegate = self as? NSUserNotificationCenterDelegate
        userNotificationCenter.scheduleNotification(userNotification)
        let soundURL = Bundle.main.url(forResource: "alert-sound", withExtension: "caf")
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL! as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
        switch getNotificationVoice() {
        case .zh_CN:
            notificationSpeak(text: timerNow["tip"]!, withVoice: "Ting-Ting")
        case .zh_HK:
            notificationSpeak(text: timerNow["tip"]!, withVoice: "Sin-ji")
        case .zh_TW:
            notificationSpeak(text: timerNow["tip"]!, withVoice: "Mei-Jia")
        default:
            notificationSpeak(text: timerNow["tip"]!, withVoice: "none")
        }
        
    }
    
    func notificationSpeak(text: String, withVoice: String) {
        if withVoice == "none" {
            return
        }
        let task = Process()
        task.launchPath = "/usr/bin/say"
        task.arguments = ["-v\(withVoice)", text]
        task.launch()
        task.waitUntilExit()
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func setCountContorls(ishidden: Bool) {
        pauseButton.isHidden = ishidden
        stopButton.isHidden = ishidden
        timeLabel.isHidden = ishidden
    }
    
    func setNormalContorls(ishidden: Bool) {
        timeSelector.isHidden = ishidden
        startButton.isHidden = ishidden
        settingsButton.isHidden = ishidden
        quitButton.isHidden = ishidden
    }
}

extension TimeGOViewController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        if arrayChanged {
            updateTimeSelectorFrom(timeArray: timeArray)
            UserDefaults.standard.set(timeArray, forKey: UserDataKeys.time)
            arrayChanged = false
        }
    }
}
