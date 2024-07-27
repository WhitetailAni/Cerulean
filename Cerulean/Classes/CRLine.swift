//
//  CRLine.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import Foundation
import AppKit

enum CRLine {
    case red
    case blue
    case blueAlternate
    case brown
    case green
    case greenAlternate
    case orange
    case pink
    case purple
    case purpleExpress
    case yellow
    
    func textualRepresentation() -> String {
        switch self {
        case .red:
            return "Red"
        case .blue, .blueAlternate:
            return "Blue"
        case .brown:
            return "Brown"
        case .green, .greenAlternate:
            return "Green"
        case .orange:
            return "Orange"
        case .pink:
            return "Pink"
        case .purple, .purpleExpress:
            return "Purple"
        case .yellow:
            return "Yellow"
        }
    }
    
    func apiRepresentation() -> String {
        switch self {
        case .red:
            return "Red"
        case .blue, .blueAlternate:
            return "Blue"
        case .brown:
            return "Brn"
        case .green, .greenAlternate:
            return "G"
        case .orange:
            return "Org"
        case .pink:
            return "Pink"
        case .purple, .purpleExpress:
            return "P"
        case .yellow:
            return "Y"
        }
    }
    
    func color() -> NSColor {
        switch self {
        case .red:
            return NSColor(r: 227, g: 25, b: 55)
        case .blue, .blueAlternate:
            return NSColor(r: 0, g: 157, b: 220)
        case .brown:
            return NSColor(r: 118, g: 66, b: 0)
        case .green, .greenAlternate:
            return NSColor(r: 0, g: 169, b: 79)
        case .orange:
            return NSColor(r: 244, g: 120, b: 54)
        case .pink:
            return NSColor(r: 243, g: 139, b: 185)
        case .purple, .purpleExpress:
            return NSColor(r: 73, g: 47, b: 146)
        case .yellow:
            return NSColor(r: 255, g: 232, b: 0)
        }
    }
    
    func link() -> URL {
        switch self {
        case .red:
            return URL(string: "https://www.transitchicago.com/redline/")!
        case .blue, .blueAlternate:
            return URL(string: "https://www.transitchicago.com/blueline/")!
        case .brown:
            return URL(string: "https://www.transitchicago.com/brownline/")!
        case .green, .greenAlternate:
            return URL(string: "https://www.transitchicago.com/greenline/")!
        case .orange:
            return URL(string: "https://www.transitchicago.com/orangeline/")!
        case .pink:
            return URL(string: "https://www.transitchicago.com/pinkline/")!
        case .purple, .purpleExpress:
            return URL(string: "https://www.transitchicago.com/purpleline/")!
        case .yellow:
            return URL(string: "https://www.transitchicago.com/yellowline/")!
        }
    }
}
