//
//  MTService.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/2/24.
//

import Foundation
import AppKit

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
                    if (trainNumber > 300 && trainNumber < 400) || trainNumber > 600 {
                        return "Blue Island - Vermont"
                    } else {
                        return "Joliet"
                    }
                }
            case .me:
                if trainNumber % 2 == 0 {
                    return "Millennium Station"
                } else {
                    if (isNumberBetween(min: 100, max: 200, value: trainNumber) && trainNumber != 165) || trainNumber == 711 || isNumberBetween(min: 800, max: 900, value: trainNumber) {
                        return "University Park"
                    } else if isNumberBetween(min: 200, max: 300, value: trainNumber) || trainNumber > 8500 {
                        return "Blue Island"
                    } else if isNumberBetween(min: 300, max: 400, value: trainNumber) || isNumberBetween(min: 8300, max: 8400, value: trainNumber) {
                        return "93rd Street/South Chicago"
                    } else if isNumberBetween(min: 600, max: 700, value: trainNumber) {
                        return "115th Street/Kensington"
                    } else if (isNumberBetween(min: 700, max: 800, value: trainNumber) && trainNumber != 711) || trainNumber == 165 {
                        return "Homewood"
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
                    case 801, 805, 809, 819, 823, 831, 301, 815, 321, 337, 347, 351, 355, 359, 363, 373:
                        return "Kenosha"
                    case 309, 341, 345, 349, 353, 357, 361:
                        return "Highland Park"
                    case 305, 391, 313:
                        return "Winnetka"
                    case 393:
                        return "Ravinia Park"
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
        return "Central Station"
    }
    
    private func isNumberBetween(min: Int, max: Int, value: Int) -> Bool {
        return min < value && value < max
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
    
    func color() -> NSColor {
        switch self {
        case .up_w:
            return NSColor(r: 254, g: 177, b: 183)
        case .hc:
            return NSColor(r: 139, g: 29, b: 64)
        case .ri:
            return NSColor(r: 224, g: 37, b: 28)
        case .me:
            return NSColor(r: 255, g: 81, b: 0)
        case .md_w:
            return NSColor(r: 243, g: 190, b: 78)
        case .md_n:
            return NSColor(r: 231, g: 114, b: 0)
        case .up_nw:
            return NSColor(r: 255, g: 206, b: 67)
        case .bnsf:
            return NSColor(r: 60, g: 173, b: 42)
        case .up_n:
            return NSColor(r: 0, g: 129, b: 62)
        case .sws:
            return NSColor(r: 0, g: 92, b: 185)
        case .ncs:
            return NSColor(r: 174, g: 149, b: 217)
        case .ses:
            return NSColor(r: 0, g: 0, b: 0)
        }
    }
    
    func outOfService() -> Bool {
        /*var weekday = Calendar.current.component(.weekday, from: Date())
        if MTService.isHoliday() {
            weekday = 1
        }
        switch self {
        case .up_w:
            if weekday == 1 || weekday == 7 {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 06), end: CRTime(hour: 6, minute: 25))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 08), end: CRTime(hour: 4, minute: 15))
            }
        case .hc:
            if isNumberBetween(min: 1, max: 7, value: weekday) {
                return !(CRTime.isItCurrentlyBetween(start: CRTime(hour: 5, minute: 45), end: CRTime(hour: 8, minute: 12)) || CRTime.isItCurrentlyBetween(start: CRTime(hour: 15, minute: 50), end: CRTime(hour: 18, minute: 36)))
            }
            return false
        case .ri:
            if isNumberBetween(min: 1, max: 7, value: weekday) {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 56), end: CRTime(hour: 6, minute: 05))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 56), end: CRTime(hour: 4, minute: 20))
            }
        case .me:
            if isNumberBetween(min: 1, max: 7, value: weekday) {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 00), end: CRTime(hour: 4, minute: 15))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 45), end: CRTime(hour: 4, minute: 40))
            }
        case .md_w:
            if isNumberBetween(min: 1, max: 7, value: weekday) {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 00, minute: 35), end: CRTime(hour: 4, minute: 17))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 55), end: CRTime(hour: 5, minute: 55))
            }
        case .md_n:
            switch weekday {
            case 1:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 57), end: CRTime(hour: 5, minute: 38))
            case 7:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 57), end: CRTime(hour: 5, minute: 38))
            default:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 15), end: CRTime(hour: 4, minute: 40))
            }
        case .up_nw:
            switch weekday {
            case 1:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 20), end: CRTime(hour: 6, minute: 35))
            case 7:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 20), end: CRTime(hour: 6, minute: 15))
            default:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 25), end: CRTime(hour: 4, minute: 15))
            }
        case .bnsf:
            if isNumberBetween(min: 1, max: 7, value: weekday) {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 51), end: CRTime(hour: 5, minute: 05))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 51), end: CRTime(hour: 4, minute: 00))
            }
        case .up_n:
            switch weekday {
            case 1:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 20), end: CRTime(hour: 6, minute: 49))
            case 7:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 20), end: CRTime(hour: 4, minute: 58))
            default:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 54), end: CRTime(hour: 4, minute: 05))
            }
        case .sws:
            if isNumberBetween(min: 1, max: 7, value: weekday) {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 00, minute: 59), end: CRTime(hour: 5, minute: 07))
            }
        case .ncs:
            if isNumberBetween(min: 1, max: 7, value: weekday) {
                return !(CRTime.isItCurrentlyBetween(start: CRTime(hour: 5, minute: 20), end: CRTime(hour: 10, minute: 49)) || CRTime.isItCurrentlyBetween(start: CRTime(hour: 13, minute: 25), end: CRTime(hour: 19, minute: 40)))
            }
        case .ses:
            return false
        }*/
        return false
    }
    
    func getPolylineKey(number: String) -> String {
        if number == "RAV1" {
            return "UP-N_OB_1"
        } else {
            let trainNumber = Int(number) ?? 0
            switch self {
            case .up_w:
                return "UP-W_OB_1"
            case .hc:
                return "HC_OB_1"
            case .ri:
                if isNumberBetween(min: 399, max: 500, value: trainNumber) || trainNumber < 200 {
                    return "RI_OB_2"
                } else {
                    return "RI_OB_1"
                }
            case .me:
                if trainNumber % 2 == 0 {
                    return "ME_OB_1"
                } else {
                    if isNumberBetween(min: 200, max: 300, value: trainNumber) || trainNumber > 8500 {
                        return "ME_OB_2"
                    } else if isNumberBetween(min: 300, max: 400, value: trainNumber) || isNumberBetween(min: 8300, max: 8400, value: trainNumber) {
                        return "ME_OB_3"
                    }
                    return "ME_OB_1"
                }
            case .md_w:
                return "MD-W_OB_1"
            case .md_n:
                return "MD-N_OB_1"
            case .up_nw:
                if [610, 624, 633, 636, 643, 657].contains(trainNumber) {
                     return "UP-NW_OB_2"
                }
                return "UP-NW_OB_1"
            case .bnsf:
                return "BNSF_OB_1"
            case .up_n:
                return "UP-N_OB_1"
            case .sws:
                return "SWS_OB_1"
            case .ncs:
                return "NCS_OB_1"
            case .ses:
                return "MD-W_OB_1"
            }
        }
    }
    
    static private func isHoliday() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        let weekday = calendar.component(.weekday, from: today)

        if month == 1 && day == 1 {
            return true
        }

        let easterDate = {
            let a = year % 19
            let b = Int(floor(Double(year) / 100))
            let c = year % 100
            let d = Int(floor(Double(b) / 4))
            let e = b % 4
            let f = Int(floor(Double(b + 8) / 25))
            let g = Int(floor(Double(b - f + 1) / 3))
            let h = (19 * a + b - d - g + 15) % 30
            let i = Int(floor(Double(c) / 4))
            let k = c % 4
            let l = (32 + 2 * e + 2 * i - h - k) % 7
            let m = Int(floor(Double(a + 11 * h + 22 * l) / 451))
            let month = Int(floor(Double(h + l - 7 * m + 114) / 31))
            let day = ((h + l - 7 * m + 114) % 31) + 1

            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day

            return Calendar.current.date(from: dateComponents)!
        }()
        if calendar.isDate(today, inSameDayAs: easterDate) {
            return true
        }

        if month == 5 && weekday == 2 && (31 - day) < 7 {
            return true
        }

        if month == 6 && day == 19 {
            return true
        }

        if month == 9 && weekday == 2 && day <= 7 {
            return true
        }

        if month == 11 && weekday == 5 && (22...28).contains(day) {
            return true
        }

        if month == 12 && day == 25 {
            return true
        }

        return false
    }
}
