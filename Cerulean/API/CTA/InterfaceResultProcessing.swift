//
//  InterfaceResultProcessing.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import Foundation
import CoreLocation

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
            if let rn = train["rn"] as? String, let destSt = train["destNm"] as? String, let destStID = train["destSt"] as? String, let time = ctatt["tmst"] as? String, let latitude: String = train["lat"] as? String, let longitude: String = train["lon"] as? String {
                trainInfoArray.append(["run": rn, "destinationStation": destSt, "destinationStationID": destStID, "requestTime": time, "latitude": latitude, "longitude": longitude])
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
            let nextStopID: String = eta["stpId"] as? String ?? "Unknown"
            let trainDirection: String = eta["trDr"] as? String ?? "2"
            let timeToArrive: String = eta["arrT"] as? String ?? "1970-01-01T00:00:00"
            
            estimatedEta["isDelayed"] = isDelayed
            estimatedEta["isBreakingDown"] = isBreakingDown
            estimatedEta["isApproachingNextStation"] = isApproachingNextStation
            estimatedEta["isScheduled"] = isScheduled
            
            
            estimatedEta["nextStation"] = nextStation
            estimatedEta["nextStopID"] = nextStopID
            estimatedEta["finalStation"] = endDestination
            estimatedEta["direction"] = trainDirection
            estimatedEta["nextStationArrivalTime"] = timeToArrive
            /*estimatedEta["latitude"] = latitude
            estimatedEta["longitude"] = longitude*/
            
            estimatedEtaArray.append(estimatedEta)
        }
        return estimatedEtaArray
    }
    
    ///secrets!
    class func debugCleanUpRunInfo(info: [String: Any]) -> [(run: String, coordinate: CLLocationCoordinate2D, terminus: String, timeLastUpdated: String)] {
        guard let ctatt = info["ctatt"] as? [String: Any], let route = ctatt["route"] as? [[String: Any]], let trains = route[0]["train"] as? [[String: Any]] else {
            return []
        }
        
        var locationArray: [(run: String, coordinate: CLLocationCoordinate2D, terminus: String, timeLastUpdated: String)] = []
        
        let timeLastUpdatedRaw = ctatt["tmst"] as? String ?? "1970-01-01T00:00:00"
        let timeLastUpdated = CRTime.ctaAPITimeToReadableTime(string: timeLastUpdatedRaw)
        
        for train in trains {
            let run: String = train["rn"] as? String ?? "0"
            let terminus: String = train["destNm"] as? String ?? "Unknown"
            let latitudeString: String = train["lat"] as? String ?? "0.0"
            let longitudeString: String = train["lon"] as? String ?? "0.0"
            
            locationArray.append((run: run, coordinate: CLLocationCoordinate2D(latitude: Double(latitudeString) ?? 2.1, longitude: Double(longitudeString) ?? 7.3), terminus: terminus, timeLastUpdated: timeLastUpdated))
        }
        return locationArray
    }
    
    ///Gets the current location and time for a given CTA run
    class func getLocationForRun(info: [String: Any]) -> (CLLocationCoordinate2D, String) {
        guard let ctatt = info["ctatt"] as? [String: Any], let position = ctatt["position"] as? [String: Any], let timeString = ctatt["tmst"] as? String else {
            return (CLLocationCoordinate2D(latitude: -2, longitude: -3), "")
        }
        
        if let latitudeString = position["lat"] as? String, let longitudeString = position["lon"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
            return (CLLocationCoordinate2D(latitude: latitude, longitude: longitude), CRTime.ctaAPITimeToReadableTime(string: timeString))
        }
        return (CLLocationCoordinate2D(latitude: -2, longitude: -3), "")
    }
}
