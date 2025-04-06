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
    case redAlternate
    case redSouthSide
    case blue
    case blueAlternate
    case brown
    case green
    case greenAlternate
    case orange
    case pink
    case pinkAlternate
    case purple
    case purpleExpress
    case yellow
    
    static var allLines: [CRLine] = [.red, .blue, .brown, .green, .orange, .pink, .purple, .yellow]
    
    static func lineForGTFSID(id: Int) -> CRLine {
        switch id {
        case 308400009, 308500011, 308500009:
            return CRLine.green
        case 308400012, 308400010, 308500010:
            return CRLine.greenAlternate
        case 308500036, 308500025, 308400025, 308400102, 308400026, 308500026, 308500102, 308400036:
            return CRLine.purple
        case 308500040, //forest park-jefferson park?
            308400001, 308400002, 308500002: //forest park-ohare
            return CRLine.blue
        case 308500053, 308500074: //ohare-uic
            return CRLine.blueAlternate
        case 308400033:
            return CRLine.yellow
        case 308400035, 308500035:
            return CRLine.pink
        case 308400017, 308500017:
            return CRLine.brown
        case 308500039: //part of brownge
            return CRLine.orange
        case 308400007, 308400008:
            return CRLine.red
        case 308500022: //part of brownge
            return CRLine.brown
        case 308400129, 308400128, 308500084, 308500128:
            return CRLine.blueAlternate
        case 308500024, 308400024:
            return CRLine.purpleExpress
        case 308400034, 308500034:
            return CRLine.orange
        case 308600001:
            return CRLine.redAlternate
        case 308600002:
            return CRLine.pinkAlternate
        case 308600003:
            return CRLine.redSouthSide
        default:
            return CRLine.red
        }
    }
    
    static func gtfsIDForLineAndRun(line: CRLine, run: Int) -> Int {
        var line2 = line
        
        if line == .purple {
            let rawTrain = ChicagoTransitInterface().getRunNumberInfo(run: String(run))
            let location = InterfaceResultProcessing.getLocationForRun(info: rawTrain, gtfs: true)
            if location.0.latitude < 42.01663 || location.1 == "Loop" {
                line2 = .purpleExpress
            }
        }
        
        switch line2 {
        case .red:
            return 308400007/*, 308400008].randomElement()!*/
        case .redAlternate:
            return 308600001
        case .redSouthSide:
            return 308600003
        case .blue:
            if run > 300 {
                return 308400129/*, 308400128, 308500084, 308500128].randomElement()!*/
            }
            return 308400001/*, 308400002, 308500002].randomElement()!*/
        case .blueAlternate:
            if run > 300 {
                return 308400129/*, 308400128, 308500084, 308500128].randomElement()!*/
            }
            return 308500053/*, 308500074].randomElement()!*/
        case .green:
            return 308400009/*, 308500011, 308500009].randomElement()!*/
        case .greenAlternate:
            return 308400012/*, 308400010, 308500010].randomElement()!*/
        case .brown:
            return 308400017/*, 308500017].randomElement()!*/
        case .orange:
            return 308400034/*, 308500034].randomElement()!*/
        case .pink:
            return 308400035/*, 308500035].randomElement()!*/
        case .pinkAlternate:
            return 308600002
        case .purple:
            return 308500036/*, 308500025, 308400025, 308400102, 308400026, 308500026, 308500102, 308400036].randomElement()!*/
        case .purpleExpress:
            return 308500024/*, 308400024, 308500026].randomElement()!*/
        case .yellow:
            return 308400033
        }
    }
    
    func textualRepresentation() -> String {
        switch self {
        case .red, .redAlternate, .redSouthSide:
            return "Red"
        case .blue, .blueAlternate:
            return "Blue"
        case .brown:
            return "Brown"
        case .green, .greenAlternate:
            return "Green"
        case .orange:
            return "Orange"
        case .pink, .pinkAlternate:
            return "Pink"
        case .purple, .purpleExpress:
            return "Purple"
        case .yellow:
            return "Yellow"
        }
    }
    
    func apiRepresentation() -> String {
        switch self {
        case .red, .redAlternate, .redSouthSide:
            return "Red"
        case .blue, .blueAlternate:
            return "Blue"
        case .brown:
            return "Brn"
        case .green, .greenAlternate:
            return "G"
        case .orange:
            return "Org"
        case .pink, .pinkAlternate:
            return "Pink"
        case .purple, .purpleExpress:
            return "P"
        case .yellow:
            return "Y"
        }
    }
    
    func color() -> NSColor {
        switch self {
        case .red, .redAlternate, .redSouthSide:
            return NSColor(r: 227, g: 25, b: 55)
        case .blue, .blueAlternate:
            return NSColor(r: 0, g: 157, b: 220)
        case .brown:
            return NSColor(r: 118, g: 66, b: 0)
        case .green, .greenAlternate:
            return NSColor(r: 0, g: 169, b: 79)
        case .orange:
            return NSColor(r: 244, g: 120, b: 54)
        case .pink, .pinkAlternate:
            return NSColor(r: 243, g: 139, b: 185)
        case .purple, .purpleExpress:
            return NSColor(r: 73, g: 47, b: 146)
        case .yellow:
            return NSColor(r: 255, g: 232, b: 0)
        }
    }
    
    func link() -> URL {
        switch self {
        case .red, .redAlternate, .redSouthSide:
            return URL(string: "https://www.transitchicago.com/redline/")!
        case .blue, .blueAlternate:
            return URL(string: "https://www.transitchicago.com/blueline/")!
        case .brown:
            return URL(string: "https://www.transitchicago.com/brownline/")!
        case .green, .greenAlternate:
            return URL(string: "https://www.transitchicago.com/greenline/")!
        case .orange:
            return URL(string: "https://www.transitchicago.com/orangeline/")!
        case .pink, .pinkAlternate:
            return URL(string: "https://www.transitchicago.com/pinkline/")!
        case .purple, .purpleExpress:
            return URL(string: "https://www.transitchicago.com/purpleline/")!
        case .yellow:
            return URL(string: "https://www.transitchicago.com/yellowline/")!
        }
    }
    
    func glyph() -> NSImage? {
        switch self {
        case .red, .redAlternate, .redSouthSide, .blue, .blueAlternate:
            return NSImage(named: "nightOwl")
        case .yellow:
            return NSImage(named: "skokieSwift")
        default:
            return nil
        }
    }
}
