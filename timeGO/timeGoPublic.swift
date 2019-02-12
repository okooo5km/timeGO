//
//  public.swift
//  timeGO
//
//  Created by 5km on 2019/1/7.
//  Copyright © 2019 5km. All rights reserved.
//
import Cocoa

protocol StatusItemUpdateDelegate {
    func timerDidStart()
    func timerDidStop()
    func timerUpdate(percent: Double)
}

struct UserDataKeys {
    static let time = "timeDataKey"
    static let voice = "voiceDataKey"
}

var timeArray = [[String: String]]()
var arrayChanged = false

struct DefaultTipInfo {
    static let no1 = NSLocalizedString("timer-default-tip-1", comment: "")
    static let no2 = NSLocalizedString("timer-default-tip-2", comment: "")
}

func getAppInfo() -> String {
    let infoDic = Bundle.main.infoDictionary
    let versionStr = infoDic?["CFBundleShortVersionString"] as! String
    return NSLocalizedString("app-name", comment: "") + " v" + versionStr
}

func getTimeArray() -> [Dictionary<String, String>] {
    var timeArray: [Dictionary<String, String>] = []
    if UserDefaults.standard.array(forKey: UserDataKeys.time) == nil {
        timeArray.append(["time": "25", "tip": DefaultTipInfo.no1])
        timeArray.append(["time": "5", "tip": DefaultTipInfo.no2])
        UserDefaults.standard.set(timeArray, forKey: UserDataKeys.time)
    } else {
        if UserDefaults.standard.array(forKey: UserDataKeys.time) is [Int] {
            UserDefaults.standard.removeObject(forKey: UserDataKeys.time)
            timeArray.append(["time": "25", "tip": DefaultTipInfo.no1])
            timeArray.append(["time": "5", "tip": DefaultTipInfo.no2])
            UserDefaults.standard.set(timeArray, forKey: UserDataKeys.time)
        } else {
            timeArray = UserDefaults.standard.array(forKey: UserDataKeys.time) as! [Dictionary<String, String>]
            
        }
    }
    return timeArray
}

enum NotificationVoice: Int {
    case none = 0
    case zh_CN = 1
    case zh_HK = 2
    case zh_TW = 3
}

func getNotificationVoice() -> NotificationVoice {
    return NotificationVoice(rawValue: UserDefaults.standard.integer(forKey: UserDataKeys.voice))!
}

func tipInfo(withTitle: String, withMessage: String) {
    let alert = NSAlert()
    alert.messageText = withTitle
    alert.informativeText = withMessage
    alert.addButton(withTitle: NSLocalizedString("tip-ok-button-title", comment: ""))
    alert.window.titlebarAppearsTransparent = true
    alert.runModal()
}

// NSTextField 支持快捷键
extension NSTextField {
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        switch event.charactersIgnoringModifiers {
        case "a":
            return NSApp.sendAction(#selector(NSText.selectAll(_:)), to: self.window?.firstResponder, from: self)
        case "c":
            return NSApp.sendAction(#selector(NSText.copy(_:)), to: self.window?.firstResponder, from: self)
        case "v":
            return NSApp.sendAction(#selector(NSText.paste(_:)), to: self.window?.firstResponder, from: self)
        case "x":
            return NSApp.sendAction(#selector(NSText.cut(_:)), to: self.window?.firstResponder, from: self)
        default:
            return super.performKeyEquivalent(with: event)
        }
    }
}
