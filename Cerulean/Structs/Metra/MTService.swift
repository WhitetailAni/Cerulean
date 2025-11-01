//
//  MTService.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/2/24.
//

import Foundation
import AppKit

enum MTServiceBranch {
    case beverly
    case south_chicago
    case blue_island
    case mchenry
    case none
}

enum MTService {
    case up_w
    case hc
    case ri
    case me
    case md_w
    case md_n
    case up_nw
    case bnsf
    case up_n
    case sws
    case ncs
    case ses
    
    init(fromAPI id: String) {
        switch id {
        case "UP-W":
            self = .up_w
        case "HC":
            self = .hc
        case "RI":
            self = .ri
        case "ME":
            self = .me
        case "MD-W":
            self = .md_w
        case "MD-N":
            self = .md_n
        case "UP-NW":
            self = .up_nw
        case "BNSF":
            self = .bnsf
        case "UP-N":
            self = .up_n
        case "SWS":
            self = .sws
        case "NCS":
            self = .ncs
        default:
            self = .ses
        }
        return
    }
    
    static var allServices = [MTService.up_w, MTService.hc, MTService.ri, MTService.me, MTService.md_w, MTService.md_n, MTService.up_nw, MTService.bnsf, MTService.up_n, MTService.sws, MTService.ncs]
    
    func getBranch(trainString: String, withOthers: Bool = false) -> MTServiceBranch {
        let trainNumber = Int(trainString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
        if self == .me {
            if isNumberBetween(min: 200, max: 299, value: trainNumber) || trainNumber > 8500 {
                return .blue_island
            } else if isNumberBetween(min: 300, max: 399, value: trainNumber) || isNumberBetween(min: 8300, max: 8399, value: trainNumber) || trainNumber == 401 {
                return .south_chicago
            }
        }
        if self == .ri && withOthers {
            let day = Calendar.current.dateComponents(in: TimeZone(identifier: "America/Chicago")!, from: Date()).weekday
            if day == 1 || day == 7 {
                if isNumberBetween(min: 200, max: 399, value: trainNumber) {
                    return .beverly
                }
            } else {
                if isNumberBetween(min: 500, max: 699, value: trainNumber) {
                    return .beverly
                }
            }
        }
        if self == .up_nw && withOthers {
            if [610, 624, 633, 636, 643, 659].contains(trainNumber) {
                return .mchenry
            }
        }
        return .none
    }
    
    func getDestination(trainString: String) -> String {
        if trainString == "RAV1" {
            return "Ravinia Park"
        } else {
            let trainNumber = Int(trainString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
            switch self {
            case .up_w:
                if trainNumber % 2 == 0 {
                    return "Ogilvie Transportation Center"
                } else {
                    switch trainNumber {
                    case 15, 45, 51:
                        return "La Fox"
                    case 43, 57:
                        return "Geneva"
                    default:
                        return "Elburn"
                    }
                }
            case .hc:
                if trainNumber % 2 == 0 {
                    return "Chicago Union Station"
                } else {
                    return "Joliet"
                }
            case .ri:
                if trainNumber % 2 == 0 {
                    return "LaSalle Street Station"
                } else {
                    if isNumberBetween(min: 300, max: 399, value: trainNumber) {
                        let day = Calendar.current.dateComponents(in: TimeZone(identifier: "America/Chicago")!, from: Date()).weekday
                        if day == 1 || day == 7 {
                            return "Blue Island/Vermont Street"
                        }
                        return "80th Avenue/Tinley Park"
                    } else if isNumberBetween(min: 600, max: 699, value: trainNumber) {
                        return "Blue Island/Vermont Street"
                    } else {
                        return "Joliet"
                    }
                }
            case .me:
                if trainNumber % 2 == 0 {
                    return "Millennium Station"
                } else {
                    if [165, 721, 723, 725].contains(trainNumber) {
                        return "Homewood"
                    } else if isNumberBetween(min: 200, max: 299, value: trainNumber) || trainNumber > 8500 {
                        return "Blue Island"
                    } else if isNumberBetween(min: 300, max: 399, value: trainNumber) || isNumberBetween(min: 8300, max: 8399, value: trainNumber) || trainNumber == 401 {
                        return "93rd Street/South Chicago"
                    } else if isNumberBetween(min: 600, max: 699, value: trainNumber) {
                        return "115th Street/Kensington"
                    } else {
                        return "University Park"
                    }
                }
            case .md_w:
                if trainNumber % 2 == 0 {
                    return "Chicago Union Station"
                } else {
                    let today = Date()
                    let month = Calendar.current.component(.month, from: today)
                    let day = Calendar.current.component(.day, from: today)
                    
                    if trainNumber > 2700 {
                        if month == 12 && (day == 24 || day == 31) {
                            return "Big Timber Road"
                        } else {
                            return "Elgin"
                        }
                    } else if trainNumber > 2400 || trainNumber == 2229 {
                        return "Franklin Park"
                    } else if trainNumber == 2233 {
                        return "National Street"
                    } else {
                        return "Big Timber Road"
                    }
                }
            case .md_n:
                if trainNumber % 2 == 0 {
                    return "Chicago Union Station"
                } else {
                    switch trainNumber {
                    case 2617, 2101, 2105, 2127, 2133:
                        return "Lake Forest"
                    case 2123:
                        return "Deerfield"
                    case 2141:
                        return "Libertyville"
                    case 2107, 2111, 2115, 2119, 2145:
                        return "Grayslake"
                    default:
                        return "Fox Lake"
                    }
                }
            case .up_nw:
                if trainNumber % 2 == 0 {
                    return "Ogilvie Transportation Center"
                } else {
                    switch trainNumber {
                    case 633, 643, 657:
                        return "McHenry"
                    case 603, 607, 613, 619, 621, 627, 631, 645, 667, 669, 675, 677, 7099, 7233, 735, 711, 713, 715, 719:
                        return "Crystal Lake"
                    case 609, 615, 635, 639, 651:
                        return "Des Plaines"
                    case 625, 673, 727, 731:
                        return "Barrington"
                    case 653, 659, 663:
                        return "Palatine"
                    default:
                        return "Harvard"
                    }
                }
            case .bnsf:
                if trainNumber % 2 == 0 {
                    return "Chicago Union Station"
                } else {
                    switch trainNumber {
                    case 1203, 1213, 1245, 1257, 1273:
                        return "Brookfield"
                    case 1207, 1215, 1243, 1249, 1255:
                        return "Fairview Avenue"
                    case 1263, 1271, 1277:
                        return "Naperville"
                    default:
                        return "Aurora"
                    }
                }
            case .up_n:
                if trainNumber % 2 == 0 {
                    return "Ogilvie Transportation Center"
                } else {
                    switch trainNumber {
                    case 803, 807, 815, 821, 823, 825, 829, 301, 303, 321, 337, 347, 351, 355, 359, 363, 373:
                        return "Kenosha"
                    case 309, 341, 345, 349, 353, 357, 361:
                        return "Highland Park"
                    case 305, 391, 313:
                        return "Winnetka"
                    case 393:
                        if CRTime.isRTASummer() {
                            return "Ravinia Park"
                        } else {
                            return "Winnetka"
                        }
                    default:
                        return "Waukegan"
                    }
                }
            case .sws:
                if trainNumber % 2 == 0 {
                    return "Chicago Union Station"
                } else {
                    if [805, 815, 821, 825, 841].contains(trainNumber) {
                        return "Manhattan"
                    } else {
                        return "179th Street/Orland Park"
                    }
                }
            case .ncs:
                if trainNumber % 2 == 0 {
                    return "Chicago Union Station"
                } else if trainNumber > 700 {
                    return "O'Hare Transfer"
                } else {
                    return "Antioch"
                }
            case .ses:
                if trainNumber % 2 == 0 {
                    return "LaSalle Street Station"
                } else {
                    return "Balmoral Park"
                }
            }
        }
    }
    
    func isNumberBetween(min: Int, max: Int, value: Int) -> Bool {
        return min <= value && value <= max
    }
        
    func apiRepresentation() -> String {
        switch self {
        case .up_w:
            return "UP-W"
        case .hc:
            return "HC"
        case .ri:
            return "RI"
        case .me:
            return "ME"
        case .md_w:
            return "MD-W"
        case .md_n:
            return "MD-N"
        case .up_nw:
            return "UP-NW"
        case .bnsf:
            return "BNSF"
        case .up_n:
            return "UP-N"
        case .sws:
            return "SWS"
        case .ncs:
            return "NCS"
        case .ses:
            return "SES"
        }
    }
    
    func textualRepresentation() -> String {
        switch self {
        case .up_w:
            return "Union Pacific West"
        case .hc:
            return "Heritage Corridor"
        case .ri:
            return "Rock Island District"
        case .me:
            return "Metra Electric District"
        case .md_w:
            return "Milwaukee District West"
        case .md_n:
            return "Milwaukee District North"
        case .up_nw:
            return "Union Pacific Northwest"
        case .bnsf:
            return "BNSF"
        case .up_n:
            return "Union Pacific North"
        case .sws:
            return "SouthWest Service"
        case .ncs:
            return "North Central Service"
        case .ses:
            return "SouthEast Service"
        }
    }
    
    func link() -> URL { //https://ridertools.metrarail.com/maps-schedules/train-lines/UP-N
        switch self {
        case .up_w:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/UP-W")!
        case .hc:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/HC")!
        case .ri:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/RI")!
        case .me:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/MED")!
        case .md_w:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/MD-W")!
        case .md_n:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/MD-N")!
        case .up_nw:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/UP-NW")!
        case .bnsf:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/BNSF")!
        case .up_n:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/UP-N")!
        case .sws:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/SWS")!
        case .ncs:
            return URL(string: "https://ridertools.metrarail.com/maps-schedules/train-lines/NCS")!
        case .ses:
            return URL(string: "https://en.wikipedia.org/wiki/SouthEast_Service")!
        }
    }
    
    func color(branch: MTServiceBranch) -> NSColor {
        switch self {
        case .up_w:
            return NSColor(r: 255, g: 177, b: 184)
        case .hc:
            return NSColor(r: 163, g: 0, b: 70)
        case .ri:
            switch branch {
            case .none, .south_chicago, .blue_island, .mchenry:
                return NSColor(r: 238, g: 49, b: 36)
            case .beverly:
                return NSColor(r: 151, g: 153, b: 155)
            }
        case .me:
            switch branch {
            case .none, .beverly, .mchenry:
                return NSColor(r: 255, g: 81, b: 0)
            case .south_chicago:
                return NSColor(r: 192, g: 192, b: 192)
            case .blue_island:
                return NSColor(r: 55, g: 195, b: 221)
            }
        case .md_w:
            return NSColor(r: 243, g: 189, b: 72)
        case .md_n:
            return NSColor(r: 232, g: 114, b: 0)
        case .up_nw:
            return NSColor(r: 255, g: 232, b: 0)
        case .bnsf:
            return NSColor(r: 61, g: 174, b: 43)
        case .up_n:
            return NSColor(r: 0, g: 132, b: 62)
        case .sws:
            return NSColor(r: 0, g: 93, b: 186)
        case .ncs:
            return NSColor(r: 146, g: 100, b: 204)
        case .ses:
            return NSColor(r: 0, g: 0, b: 0)
        }
    }
    
    func textColor(branch: MTServiceBranch) -> NSColor {
        switch self {
        case .up_w, .md_w, .up_nw, .me, .bnsf:
            if self == .me {
                if [.south_chicago, .blue_island].contains(branch) {
                    return NSColor(r: 0, g: 0, b: 0)
                } else {
                    return NSColor(r: 255, g: 255, b: 255)
                }
            }
            return NSColor(r: 0, g: 0, b: 0)
        default:
            return NSColor(r: 255, g: 255, b: 255)
        }
    }
    
    func getPolylineKey(number: String) -> String {
        let trainNumber = Int(number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
        var inOut = "OB"
        if trainNumber % 2 == 0 {
            inOut = "IB"
        }
        if number == "RAV1" {
            return "UP-N_\(inOut)_1"
        } else {
            switch self {
            case .up_w:
                return "UP-W_\(inOut)_1"
            case .hc:
                return "HC_\(inOut)_1"
            case .ri:
                let day = Calendar.current.dateComponents(in: TimeZone(identifier: "America/Chicago")!, from: Date()).weekday
                if day == 1 || day == 7 {
                    if trainNumber < 200 {
                        return "RI_\(inOut)_2"
                    } else {
                        return "RI_\(inOut)_1"
                    }
                } else {
                    if isNumberBetween(min: 300, max: 599, value: trainNumber) {
                        return "RI_\(inOut)_2"
                    } else {
                        return "RI_\(inOut)_1"
                    }
                }
            case .me:
                if isNumberBetween(min: 200, max: 299, value: trainNumber) || trainNumber > 8500 {
                    return "ME_\(inOut)_2"
                } else if isNumberBetween(min: 300, max: 399, value: trainNumber) || isNumberBetween(min: 8300, max: 8400, value: trainNumber) {
                    return "ME_\(inOut)_3"
                }
                return "ME_\(inOut)_1"
            case .md_w:
                return "MD-W_\(inOut)_1"
            case .md_n:
                return "MD-N_\(inOut)_1"
            case .up_nw:
                if [610, 624, 633, 636, 643, 657].contains(trainNumber) {
                     return "UP-NW_\(inOut)_2"
                }
                return "UP-NW_\(inOut)_1"
            case .bnsf:
                return "BNSF_\(inOut)_1"
            case .up_n:
                return "UP-N_\(inOut)_1"
            case .sws:
                return "SWS_\(inOut)_1"
            case .ncs:
                if trainNumber == 120 {
                    return "NCS_IB_2"
                }
                return "NCS_\(inOut)_1"
            case .ses:
                return "MD-W_\(inOut)_1"
            }
        }
    }
}
