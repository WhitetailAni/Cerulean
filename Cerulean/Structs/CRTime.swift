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
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/Chicago")!
        let current = CRTime(hour: calendar.component(.hour, from: now), minute: calendar.component(.minute, from: now))
        
        if start < end {
            return start <= current && current < end
        } else {
            return current >= start || current < end
        }
    }
    
    static func dateToReadableTime(date: Date) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return outputFormatter.string(from: date)
    }
    
    static func ctaAPITimeToReadableTime(string: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        let time: Date = inputFormatter.date(from: string) ?? Date(timeIntervalSince1970: 0)
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return outputFormatter.string(from: time)
    }
    
    static func ctaAPITimeToDate(string: String) -> Date {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        let time: Date = inputFormatter.date(from: string) ?? Date(timeIntervalSince1970: 0)
        
        return time
    }
    
    static func metraAPITimeToReadableTime(string: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.timeZone = TimeZone(identifier: "UTC")
        let time: Date = inputFormatter.date(from: string) ?? Date(timeIntervalSince1970: 0)
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return outputFormatter.string(from: time)
    }
    
    static func metraAPITimeToDate(string: String) -> Date {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.timeZone = TimeZone(identifier: "UTC")
        return inputFormatter.date(from: string) ?? Date(timeIntervalSince1970: 0)
    }
    
    static func amtrakAPITimeToReadableTime(string: String, timeZone: TimeZone, actual: Bool = false) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        inputFormatter.timeZone = timeZone//TimeZone(identifier: "UTC")
        let time: Date = inputFormatter.date(from: string) ?? Date(timeIntervalSince1970: 0)
        
        if time < Date() && actual {
            return "ALREADYHAPPEN"
        }
        
        let testFormatter = DateFormatter()
        testFormatter.dateFormat = "MM-dd"
        testFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        let outputFormatter = DateFormatter()
        if testFormatter.string(from: time) == testFormatter.string(from: Date()) {
            outputFormatter.dateFormat = "HH:mm"
        } else {
            outputFormatter.dateFormat = "MM-dd HH:mm"
        }
        outputFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return outputFormatter.string(from: time)
    }
}
