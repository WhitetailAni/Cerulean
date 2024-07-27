//
//  CRTime.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import Foundation

struct CRTime: Comparable {
    let hour: Int
    let minute: Int
    
    static func < (lhs: CRTime, rhs: CRTime) -> Bool {
        return lhs.hour * 60 + lhs.minute < rhs.hour * 60 + rhs.minute
    }
    
    static func == (lhs: CRTime, rhs: CRTime) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    
    static func isItCurrentlyBetween(start: CRTime, end: CRTime) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let current = CRTime(hour: calendar.component(.hour, from: now), minute: calendar.component(.minute, from: now))
        
        if start < end {
            return start <= current && current < end
        } else {
            return current >= start || current < end
        }
    }
    
    static func apiTimeToReadabletime(string: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        let time: Date = inputFormatter.date(from: string) ?? Date(timeIntervalSince1970: 0)
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return outputFormatter.string(from: time)
    }
}
