//
//  SettingsViewController.swift
//  timeGO
//
//  Created by 5km on 2019/1/7.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var appInfoLabel: NSTextField!
    @IBOutlet weak var timeTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        appInfoLabel.stringValue = getAppInfo()
        timeArray = getTimeArray()
        timeTableView.delegate = self
        timeTableView.dataSource = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        timeTableView.reloadData()
    }
    
    @IBAction func aboutApp(_ sender: Any) {
        tipInfo(withTitle: "关于", withMessage: "\(getAppInfo()) 是一款简单的计时提醒软件，您可以通过不同计时器组合得到番茄时钟！\n\n因你看见，所以存在！感谢您的支持！\n\nhttps://www.smslit.top/2019/01/08/timeGO/")
    }
    
    @IBAction func feedbackApp(_ sender: Any) {
        let emailBody           = "因你看见，所以存在！"
        let emailService        =  NSSharingService.init(named: NSSharingService.Name.composeEmail)!
        emailService.recipients = ["5km@smslit.cn"]
        emailService.subject    = "timeGO 反馈"
        
        if emailService.canPerform(withItems: [emailBody]) {
            emailService.perform(withItems: [emailBody])
        } else {
            tipInfo(withTitle: "反馈信息", withMessage: "您有什么问题向 5km@smslit.cn 发送邮件反馈即可！感谢您的支持！")
        }
    }
    
    @IBAction func removeTimeTableRow(_ sender: Any) {
        let selectedRow = timeTableView.selectedRow
        if selectedRow == -1 {
            tipInfo(withTitle: "提醒", withMessage: "没有选择要删除的计时器！")
            return
        }
        timeArray.remove(at: selectedRow)
        timeTableView.reloadData()
        timeTableView.selectRowIndexes([selectedRow - 1], byExtendingSelection: false)
        arrayChanged = true
    }

    @IBAction func addTimeTableRow(_ sender: Any) {
        timeArray.append(["time": "25", "tip": "请修改此处为您想要的通知消息！", "tag": "25分钟"])
        timeTableView.reloadData()
        arrayChanged = true
    }
}

extension SettingsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return timeArray.count
    }
}

extension SettingsViewController: NSTableViewDelegate {

    fileprivate enum CellIdentifier {
        static let timeID = NSUserInterfaceItemIdentifier(rawValue: "timeCellID")
        static let tipID = NSUserInterfaceItemIdentifier(rawValue: "tipCellID")
        static let tagID = NSUserInterfaceItemIdentifier(rawValue: "tagCellID")
    }
    
    fileprivate enum TextFieldPlaceHolder {
        static let time = "time"
        static let tip = "tip"
        static let tag = "tag"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""
        let item: [String: String] = timeArray[row]
        let cellView: NSTextField = NSTextField()

        switch tableColumn?.identifier {
        case CellIdentifier.timeID:
            text = item["time"]!
            cellView.placeholderString = TextFieldPlaceHolder.time
        case CellIdentifier.tipID:
            text = item["tip"]!
            cellView.placeholderString = TextFieldPlaceHolder.tip
        case CellIdentifier.tagID:
            text = item["tag", default: ""]
            cellView.placeholderString = TextFieldPlaceHolder.tag
        default:
            return nil
        }

        cellView.appearance = tableView.appearance
        cellView.backgroundColor = NSColor.clear
        cellView.stringValue = text
        cellView.isEditable = true
        cellView.font = NSFont.systemFont(ofSize: 11, weight: NSFont.Weight.light)
        cellView.isBordered = false
        cellView.delegate = self

        return cellView
    }
}

extension SettingsViewController: NSTextFieldDelegate {
    // 监听表格单元格中是否完成修改
    func controlTextDidEndEditing(_ notification: Notification) {
        let textField = notification.object as! NSTextField
        let key = textField.placeholderString!
        let index = timeTableView.selectedRow
        
        if key == TextFieldPlaceHolder.time {
            if 0 == getIntFromString(str: textField.stringValue) {
                textField.stringValue = "请输入整数"
                return
            }
        }
        if index > -1 {
            timeArray[index][key] = textField.stringValue
            arrayChanged = true
        }
        print(timeArray)
    }
}
