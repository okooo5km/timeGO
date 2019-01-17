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

let timeDataKey = "timeDataKey"
var timeArray = [[String: String]]()
var arrayChanged = false
enum DefaultTipInfo: String {
    case no1 = "搬砖很累吧！该休息了！"
    case no2 = "休息的差不多了，起来继续搬砖！"
}

func getAppInfo() -> String {
    let infoDic = Bundle.main.infoDictionary
    let appNameStr = infoDic?["CFBundleName"] as! String
    let versionStr = infoDic?["CFBundleShortVersionString"] as! String
    return appNameStr + " v" + versionStr
}

func getTimeArray() -> [Dictionary<String, String>] {
    var timeArray: [Dictionary<String, String>] = []
    if UserDefaults.standard.array(forKey: timeDataKey) == nil {
        timeArray.append(["time": "25", "tip": DefaultTipInfo.no1.rawValue])
        timeArray.append(["time": "5", "tip": DefaultTipInfo.no2.rawValue])
        UserDefaults.standard.set(timeArray, forKey: timeDataKey)
    } else {
        if UserDefaults.standard.array(forKey: timeDataKey) is [Int] {
            UserDefaults.standard.removeObject(forKey: timeDataKey)
            timeArray.append(["time": "25", "tip": DefaultTipInfo.no1.rawValue])
            timeArray.append(["time": "5", "tip": DefaultTipInfo.no2.rawValue])
            UserDefaults.standard.set(timeArray, forKey: timeDataKey)
        } else {
            timeArray = UserDefaults.standard.array(forKey: timeDataKey) as! [Dictionary<String, String>]
            
        }
    }
    return timeArray
}

func tipInfo(withTitle: String, withMessage: String) {
    let alert = NSAlert()
    alert.messageText = withTitle
    alert.informativeText = withMessage
    alert.addButton(withTitle: "确定")
    alert.runModal()
}
