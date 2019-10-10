//
//  TimeGOViewController.swift
//  timeGO
//
//  Created by 5km on 2019/1/5.
//  Copyright © 2019 5km. All rights reserved.
//
import Cocoa
import UserNotifications

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
            startButton.isEnabled = false
            return
        }
        for timeItem in timeArray {
            let timeTag = timeItem["tag", default:""]
            var timeValue = timeItem["time", default: "0"]
            if timeValue.isNumeric {
                timeValue = "\(timeItem["time", default: "0"]) \(NSLocalizedString("minutes-name", comment: ""))"
            } else {
                let indexArray = timeValue.parseTimerExpression()
                timeValue = ""
                for index in indexArray {
                    let text = timeArray[index]["time"]!
                    timeValue = timeValue + text + "+"
                }
                timeValue.removeLast()
                timeValue += " \(NSLocalizedString("minutes-name", comment: ""))"
            }
            let timeTip = timeItem["tip", default: NSLocalizedString("tip-default-content", comment: "")]
            var itemTitle = (timeTag == "") ? timeValue : "\(timeTag)(\(timeValue))"
            while timeSelector.itemTitles.contains(itemTitle) {
                itemTitle.append("\'")
            }
            timeSelector.addItem(withTitle: itemTitle)
            timeSelector.item(withTitle: itemTitle)?.toolTip = timeTip
        }
        timeSelector.selectItem(at: 0)
        startButton.isEnabled = true
    }
    
    @IBAction func startTimer(_ sender: Any) {
        if timeSelector.itemArray.count == 0 {
            return
        }
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
            if let timeGo = delegate {
                timeGo.timerDidStart()
            }
        } else {
            tipInfo(withTitle: NSLocalizedString("timer-modify-tip-title", comment: ""), withMessage: NSLocalizedString("timer-modify-tip-content", comment: ""))
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
                tipInfo(withTitle: NSLocalizedString("timer-modify-tip-title", comment: ""), withMessage: NSLocalizedString("timer-modify-tip-content", comment: ""))
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
        if let timeGo = delegate {
            timeGo.timerDidStop()
        }
        if timerIndexQueue.count > 0 {
            startSingleTimer()
        }
    }
    
    @objc func timerCountHandler(_ sender: Any) {
        if timeToCount > 0 {
            timeToCount -= 1
            timeLabel.stringValue = "\(timeToCount / 60)'\(timeToCount % 60)\""
            if let timeGo = delegate {
                let percent = 1.0 - Double(timeToCount) / Double(timeToEnd)
                timeGo.timerUpdate(percent: percent)
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
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else {
                notificationCenter.requestAuthorization(options: [.alert, .sound])
                { (granted, error) in
                   // Enable or disable features based on authorization.
                }
                return
            }
        }
        
        let content = UNMutableNotificationContent()
        content.body = timerNow["tip"]!
        content.sound = UNNotificationSound.default
        var prefixTitle = timerNow["tag"]!
        if timerNow["tag"] != "" { prefixTitle += " ･ " }
        let timeTitle = timerNow["time"]!
        let subfixTitle = NSLocalizedString("minutes-name", comment: "")
        content.title = prefixTitle + timeTitle + subfixTitle
        
        let request = UNNotificationRequest(identifier: "TIME_GO_TIME_OUT_REQUEST",
                                            content: content,
                                            trigger: nil)
        notificationCenter.add(request) { error in
            if error != nil {
                print(error.debugDescription)
            }
        }
        
        if UserDefaults.standard.bool(forKey: UserDataKeys.voice) {
            notificationSpeak(text: timerNow["tip"]!, withVoice: getNotificationVoice(lang: currentLanguage))
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

extension TimeGOViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
