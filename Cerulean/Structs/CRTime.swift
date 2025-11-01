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
    
    static func unixTimestampToReadableTime(timestamp: Double) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        return outputFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }

    static func isRTASummer() -> Bool {
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        
        return now >= memorialDayIs(year: year) && now <= laborDayIs(year: year)
    }

    static func memorialDayIs(year: Int) -> Date {
        let calendar = Calendar.current
        
        var components = DateComponents()
        components.year = year
        components.month = 5
        components.day = 31
        
        let sydney = calendar.date(from: components)!
        return calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: sydney) + 5) % 7, to: sydney)!
    }

    static func laborDayIs(year: Int) -> Date {
        let calendar = Calendar.current
        
        var components = DateComponents()
        components.year = year
        components.month = 9
        components.day = 1
        
        let platteville = calendar.date(from: components)!
        return calendar.date(byAdding: .day, value: (9 - calendar.component(.weekday, from: platteville)) % 7, to: platteville)!
    }
}
