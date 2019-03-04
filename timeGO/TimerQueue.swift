//
//  TimeQueue.swift
//  timeGO
//
//  Created by 5km on 2019/1/17.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa

struct TimerIndexQueue {
    
    private var elements: [Int] = []
    
    init() { }
    
    // MARK: - Getters
    
    var count: Int {
        return elements.count
    }
    
    var isEmpty: Bool {
        return elements.isEmpty
    }
    
    var peek: Int? {
        return elements.first
    }
    
    // MARK: - Enqueue & Dequeue
    
    mutating func enqueue(_ element: Int) {
        elements.append(element)
    }
    
    @discardableResult
    mutating func dequeue() -> Int? {
        return isEmpty ? nil : elements.removeFirst()
    }
}

extension TimerIndexQueue: CustomStringConvertible {
    var description: String {
        return elements.description
    }
}

extension String {
    
    var isTimerExpression: Bool {
        var str1 = replacingOccurrences(of: " ", with: "")
        if str1.hasPrefix("$") && str1.hasSuffix("$") && str1.count > 1 {
            str1.removeFirst()
            str1.removeLast()
            return !isEmpty && str1.range(of: "[^ 0-9+]", options: .regularExpression) == nil
        }
        return false
    }
    
    var isNumeric: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    func toInt() -> Int {
        if let number = Int(self) {
            return number
        }
        return 0
    }
    
    func parseTimerExpression() -> [Int] {
        if !isTimerExpression {
            return [Int]()
        }
        var indexArray = [Int]()
        var str1 = replacingOccurrences(of: " ", with: "")
        str1.removeFirst()
        str1.removeLast()
        let items = str1.split(separator: "+")
        for item in items {
            indexArray.append(String(item).toInt())
        }
        return indexArray
    }
    
}
