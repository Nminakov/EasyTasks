//
//  TimeRange.swift
//  Homework Tasks
//
//  Created by Nikitay on 11/8/20.
//

import Foundation

struct TimeRange {
    let from, to: Time
    
    var formattedRange: String {
        return from.formattedTime + " - " + to.formattedTime
    }
}

extension TimeRange: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        let components = value.components(separatedBy: " - ").map { Time(stringLiteral: $0) }
        guard
            let firstComponents = components.first,
            let secondComponent = components.last else {
            from = Time(stringLiteral: "00:00")
            to = Time(stringLiteral: "00:00")
            return
        }
        from = firstComponents
        to = secondComponent
    }
}

struct Time {
    let hour, minute: Int
    
    var formattedTime: String {
        return String(format: "%.2d:%.2d", hour, minute)
    }
}

extension Time: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        let components = value.components(separatedBy: ":").map { Int($0) ?? 0 }
        guard
            let firstComponents = components.first,
            let secondComponent = components.last else {
            hour = 0
            minute = 0
            return
        }
        hour = firstComponents
        minute = secondComponent
    }
}

extension Time: Comparable {
    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.hour < rhs.hour || lhs.hour == rhs.hour && lhs.minute < rhs.minute
    }
    
    static func > (lhs: Time, rhs: Time) -> Bool {
        return lhs.hour > rhs.hour || lhs.hour == rhs.hour && lhs.minute > rhs.minute
    }
}
