//
//  InterfaceResultProcessing.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

class InterfaceResultProcessing {
    
    ///Turns the CTA's Train Tracker API response for all runs along a line
    class func cleanUpLineInfo(info: [String: Any]) -> [[String: String]] {
        guard let ctatt = info["ctatt"] as? [String: Any],
              let routes = ctatt["route"] as? [[String: Any]] else {
            return []
        }
        
        var trainInfoArray: [[String: String]] = []
        
        guard let trains = routes[0]["train"] as? [[String: Any]] else {
            return []
        }
        
        for train in trains {
            if let rn = train["rn"] as? String, let destSt = train["destNm"] as? String {
                trainInfoArray.append(["run": rn, "destinationStation": destSt])
            }
        }
        
        return trainInfoArray
    }
    
    ///Turns the CTA's Train Tracker API response for individual trains into clean and easy to read data
    class func cleanUpRunInfo(info: [String: Any]) -> [[String: String]] {
        guard let ctatt = info["ctatt"] as? [String: Any], let etas = ctatt["eta"] as? [[String: Any]] else {
            return []
        }
        
        var estimatedEtaArray: [[String: String]] = []
        
        for eta in etas {
            var estimatedEta: [String: String] = [:]
             
            let endDestination: String = eta["destNm"] as? String ?? "Unknown"
            let isApproachingNextStation: String = eta["isApp"] as? String ?? "2"
            let isDelayed: String = eta["isDly"] as? String ?? "2"
            let isBreakingDown: String = eta["isFlt"] as? String ?? "2"
            let isScheduled: String = eta["isSch"] as? String ?? "2"
            let nextStation: String = eta["staNm"] as? String ?? "Unknown"
            let trainDirection: String = eta["trDr"] as? String ?? "2"
            let timeToArrive: String = eta["arrT"] as? String ?? "1970-01-01T00:00:00"
            
            let latitude: String = eta["lat"] as? String ?? "0"
            let longitude: String = eta["lon"] as? String ?? "0"
            
            switch isDelayed {
            case "0":
                estimatedEta["isDelayed"] = "No"
            case "1":
                estimatedEta["isDelayed"] = "Yes"
            default:
                estimatedEta["isDelayed"] = "Unknown"
            }
            
            switch isBreakingDown {
            case "0":
                estimatedEta["isBreakingDown"] = "No"
            case "1":
                estimatedEta["isBreakingDown"] = "Yes"
            default:
                estimatedEta["isBreakingDown"] = "Unknown"
            }
            
            switch isApproachingNextStation {
            case "0":
                estimatedEta["isApproachingNextStation"] = "No"
            case "1":
                estimatedEta["isApproachingNextStation"] = "Yes"
            default:
                estimatedEta["isApproachingNextStation"] = "Unknown"
            }
            
            switch isScheduled {
            case "0":
                estimatedEta["isScheduled"] = "No"
            case "1":
                estimatedEta["isScheduled"] = "Yes"
            default:
                estimatedEta["isScheduled"] = "Unknown"
            }
            
            estimatedEta["nextStation"] = nextStation
            estimatedEta["finalStation"] = endDestination
            estimatedEta["direction"] = trainDirection
            estimatedEta["nextStationArrivalTime"] = timeToArrive
            estimatedEta["latitude"] = latitude
            estimatedEta["longitude"] = longitude
            
            estimatedEtaArray.append(estimatedEta)
        }
        return estimatedEtaArray
    }
}
