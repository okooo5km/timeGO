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
    @IBOutlet weak var voiceNoneButton: NSButton!
    @IBOutlet weak var voiceCNButton: NSButton!
    @IBOutlet weak var voiceHKButton: NSButton!
    @IBOutlet weak var voiceTWButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        appInfoLabel.stringValue = getAppInfo()
        timeArray = getTimeArray()
        timeTableView.delegate = self
        timeTableView.dataSource = self
        switch getNotificationVoice() {
        case .zh_CN:
            voiceCNButton.state = NSButton.StateValue.on
        case .zh_HK:
            voiceHKButton.state = NSButton.StateValue.on
        case .zh_TW:
            voiceTWButton.state = NSButton.StateValue.on
        default:
            voiceNoneButton.state = NSButton.StateValue.on
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        timeTableView.reloadData()
    }
    
    @IBAction func aboutApp(_ sender: Any) {
        tipInfo(withTitle: NSLocalizedString("about-title", comment: ""), withMessage: "\(getAppInfo()) \(NSLocalizedString("about-content", comment: ""))")
    }
    
    @IBAction func feedbackApp(_ sender: Any) {
        let emailBody           = ""
        let emailService        =  NSSharingService.init(named: NSSharingService.Name.composeEmail)!
        emailService.recipients = ["5km@smslit.cn"]
        emailService.subject    = getAppInfo() + " -> Feedback"
        
        if emailService.canPerform(withItems: [emailBody]) {
            emailService.perform(withItems: [emailBody])
        } else {
            tipInfo(withTitle: NSLocalizedString("feedback-tip-title", comment: ""), withMessage: NSLocalizedString("feedback-tip-message", comment: ""))
        }
    }
    
    @IBAction func removeTimeTableRow(_ sender: Any) {
        let selectedRow = timeTableView.selectedRow
        if selectedRow == -1 {
            tipInfo(withTitle: NSLocalizedString("timer-remove-tip-title", comment: ""), withMessage: NSLocalizedString("timer-remove-tip-message", comment: ""))
            return
        }
        timeArray.remove(at: selectedRow)
        timeTableView.reloadData()
        timeTableView.selectRowIndexes([selectedRow - 1], byExtendingSelection: false)
        arrayChanged = true
    }

    @IBAction func addTimeTableRow(_ sender: Any) {
        timeArray.append(["time": "25", "tip": NSLocalizedString("timer-add-prehold-tip", comment: ""), "tag": ""])
        timeTableView.reloadData()
        arrayChanged = true
    }
    
    @IBAction func voiceChoiceChanged(_ sender: NSButton) {
        UserDefaults.standard.set(sender.toolTip!.toInt(), forKey: UserDataKeys.voice)
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
            if !(textField.stringValue.isNumeric || textField.stringValue.isTimerExpression) {
                textField.stringValue = NSLocalizedString("timer-add-exp-tip", comment: "")
                return
            }
        }
        if index > -1 {
            timeArray[index][key] = textField.stringValue
            arrayChanged = true
        }
    }
}
