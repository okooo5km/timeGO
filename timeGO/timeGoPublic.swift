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
    static let no1 = "搬砖很累吧！该休息了！"
    static let no2 = "休息的差不多了，起来继续搬砖！"
}

func getAppInfo() -> String {
    let infoDic = Bundle.main.infoDictionary
    let appNameStr = infoDic?["CFBundleName"] as! String
    let versionStr = infoDic?["CFBundleShortVersionString"] as! String
    return appNameStr + " v" + versionStr
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
    alert.addButton(withTitle: "确定")
    alert.window.titlebarAppearsTransparent = true
    alert.runModal()
}
