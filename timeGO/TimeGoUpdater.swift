//
//  TimeGoUpdater.swift
//  timeGO
//
//  Created by 5km on 2019/3/2.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa


class TimeGoUpdater {
    
    private var url: URL?
    private var callback: (()->Void)
    
    init(user: String, callback: @escaping (()->Void)) {
        let proName = Bundle.main.infoDictionary!["CFBundleExecutable"]!
        let url = "https://raw.githubusercontent.com/smslit/\(proName)/master/\(proName)/Info.plist"
        self.url = URL(string: url)
        self.callback = callback
    }
    
    func check() {
        checkRequest(checkUpdateRequestSuccess(data:response:error:))
    }
    
    private func checkRequest(_ completionHandler: @escaping ((Data?,URLResponse?,Error?)->Void)) {
        let session = URLSession(configuration: .default)
        if let url = self.url {
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request, completionHandler: completionHandler)
            task.resume()
        }
    }
    
    // 检查更新请求成功后要执行的
    private func checkUpdateRequestSuccess(data:Data?, response:URLResponse?, error:Error?) -> Void {
        DispatchQueue.main.async {
            self.callback()
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    // :TODO 加日志
                    tipInfo(withTitle: NSLocalizedString("check-update-tip.title", comment: "检查更新"),
                            withMessage: NSLocalizedString("check-update-tip-network.message", comment: "网络异常！"))
                    return
                }
                var propertyListForamt = PropertyListSerialization.PropertyListFormat.xml
                do {
                    let infoPlist = try PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.ReadOptions.mutableContainersAndLeaves, format: &propertyListForamt) as! [String: AnyObject]
                    let latestVersion = infoPlist["CFBundleShortVersionString"] as! String
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    if latestVersion == appVersion {
                        tipInfo(withTitle: NSLocalizedString("check-update-tip.title", comment: "检查更新"),
                                withMessage: NSLocalizedString("check-update-tip-none.message", comment: "没有更新！"))
                        return
                    }
                    
                    let alert = NSAlert()
                    alert.alertStyle = NSAlert.Style.informational
                    alert.messageText = NSLocalizedString("check-update-tip.title", comment: "检查更新")
                    alert.informativeText = NSLocalizedString("check-update-tip-get.message", comment: "发现新版本") + " v\(latestVersion)"
                    alert.addButton(withTitle: NSLocalizedString("check-update-tip-get-gobutton.title", comment: "前往下载"))
                    alert.addButton(withTitle: NSLocalizedString("check-update-tip-get-ignorebutton.title", comment: "忽略"))
                    alert.window.titlebarAppearsTransparent = true
                    if alert.runModal() == .alertFirstButtonReturn {
                        if let url = URL(string: "https://github.com/smslit/\(Bundle.main.infoDictionary!["CFBundleExecutable"]!)/releases/tag/v" + latestVersion) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                } catch {
                    // :TODO 加日志
                    print("Error reading plist: \(error), format: \(propertyListForamt)")
                }
            }
        }
    }
    
}
