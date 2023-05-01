//
//  CustomHoverButton.swift
//  timeGO
//
//  Created by 十里 on 2023/5/1.
//  Copyright © 2023 5km. All rights reserved.
//

import Cocoa

class CustomHoverButton: NSButton {
    
    var iconNormal: NSImage?
    var iconHover: NSImage?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setUpTrackingArea()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpTrackingArea()
    }
    
    func setUpTrackingArea() {
        let trackingArea = NSTrackingArea(rect: bounds,
                                          options: [.mouseEnteredAndExited, .activeAlways],
                                          owner: self,
                                          userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Customize your images here.
        iconNormal = NSImage(named: "CloseIconInactive")
        iconHover = NSImage(named: "CloseIcon")
        image = iconNormal
    }
    
    // Update the button's image when the mouse enters the tracking area.
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        image = iconHover
    }
    
    // Update the button's image back to normal state when the mouse exits the tracking area.
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        image = iconNormal
    }
}
