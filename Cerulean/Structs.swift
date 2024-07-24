//
//  Structs.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import SwiftUI
import Foundation
import CoreLocation

enum Line {
    case red
    case blue
    case green
    case brown
    case orange
    case pink
    case purple
    case yellow
    
    func textualRepresentation() -> String {
        switch self {
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        case .green:
            return "Green"
        case .brown:
            return "Brown"
        case .orange:
            return "Orange"
        case .pink:
            return "Pink"
        case .purple:
            return "Purple"
        case .yellow:
            return "Yellow"
        }
    }
    
    func apiRepresentation() -> String {
        switch self {
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        case .green:
            return "G"
        case .brown:
            return "Brn"
        case .orange:
            return "Org"
        case .pink:
            return "Pink"
        case .purple:
            return "P"
        case .yellow:
            return "Y"
        }
    }
    
    func barIndex() -> Int {
        switch self {
        case .red:
            return 0
        case .blue:
            return 1
        case .green:
            return 2
        case .brown:
            return 3
        case .orange:
            return 4
        case .pink:
            return 5
        case .purple:
            return 6
        case .yellow:
            return 7
        }
    }
}

struct Time: Comparable {
    let hour: Int
    let minute: Int
    
    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.hour * 60 + lhs.minute < rhs.hour * 60 + rhs.minute
    }
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    
    static func isItCurrentlyBetween(start: Time, end: Time) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let current = Time(hour: calendar.component(.hour, from: now), minute: calendar.component(.minute, from: now))
        
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
