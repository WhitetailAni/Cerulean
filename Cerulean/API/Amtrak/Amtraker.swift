//
//  Amtraker.swift
//  Cerulean
//
//  Created by WhitetailAni on 1/3/25.
//

import Foundation
import CoreLocation
import MapKit

class Amtraker: NSObject {
    let semaphore = DispatchSemaphore(value: 0)
    var baseURL = "https://api-v3.amtraker.com/v3/"
    
    var polylines: [String: [CLLocationCoordinate2D]] = [:]
    public static var polyline = Amtraker(polyline: true)
    
    override init() {
        super.init()
    }
    
    init(polyline: Bool) {
        super.init()
        storePolylines()
    }
    
    func storePolylines() {
        var pointDict: [String: [CLLocationCoordinate2D]] = [:]
        
        guard let filePath = Bundle.main.path(forResource: "amtrak", ofType: "csv") else {
            print("fuck")
            return
        }
        
        var rawList = ""
        
        do {
            rawList = try String(contentsOfFile: filePath)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        var rows = rawList.components(separatedBy: "\n")
        rows.removeFirst()
        
        for i in 0..<rows.count {
            let columns = rows[i].split(separator: ",")
            if columns.count > 0 {
                let id = String(columns[0])
                let latitude = Double(columns[1]) ?? -4.0
                let longitude = Double(columns[2]) ?? -4.0
                if pointDict[id] == nil {
                    pointDict[id] = []
                }
                pointDict[id]?.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
        polylines = pointDict
    }
    
    class func sortTrains(trains: [AMTrain]) -> [String: [AMTrain]] {
        return Dictionary(grouping: trains) { $0.trainName }
    }
    
    func getAllTrains() -> [AMTrain] {
        var returnedData: [String: Any] = [:]
        var trains: [AMTrain] = []
        
        trak(url: URL(string: "\(baseURL)trains")!) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        //print(returnedData)
        
        for key in returnedData.keys {
            let rawTrainOne: [[String: Any]] = returnedData[key] as? [[String: Any]] ?? []
            if rawTrainOne.count > 0 {
                let rawTrain = rawTrainOne[0]
                
                if !(rawTrain["provider"] as? String == "Via") {
                    if let train = processRawTrain(rawTrain: rawTrain) {
                        trains.append(train)
                    }
                }
            }
        }
        
        return trains
    }
    
    func getTrainForId(id: String) {
        
    }
    
    private func processRawTrain(rawTrain: [String: Any]) -> AMTrain? {
        if let speed = rawTrain["velocity"] as? Double,
            let trainName = rawTrain["routeName"] as? String,
            let trainNumber = rawTrain["trainNum"] as? String, let trainId = rawTrain["trainID"] as? String,
            let rawStations = rawTrain["stations"] as? [[String: Any]],
            let latitude = rawTrain["lat"] as? Double,
            let longitude = rawTrain["lon"] as? Double,
            let trainStateRaw = rawTrain["trainState"] as? String,
           
            let timestampLastUpdated = rawTrain["updatedAt"] as? String,
           
            let destStationName = rawTrain["destName"] as? String,
            let destStationTimeZoneRaw = rawTrain["destTZ"] as? String,
           
            let nextStationName = rawTrain["eventName"] as? String,
            let nextStationTimeZoneRaw = rawTrain["eventTZ"] as? String {
            
            if let destStationTimeZone = TimeZone(identifier: destStationTimeZoneRaw),
                let nextStationTimeZone = TimeZone(identifier: nextStationTimeZoneRaw) {
                let timeLastUpdated = CRTime.amtrakAPITimeToReadableTime(string: timestampLastUpdated, timeZone: TimeZone(secondsFromGMT: 0)!)
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                var stops: [AMStop] = []
                for rawStation in rawStations {
                    if let arrivalTimeRaw = rawStation["arr"] as? String,
                       let departureTimeRaw = rawStation["dep"] as? String,
                       let name = rawStation["name"] as? String,
                        let scheduledArrivalTimeRaw = rawStation["schArr"] as? String,
                        let scheduledDepartureTimeRaw = rawStation["schDep"] as? String,
                        let status = rawStation["status"] as? String,
                        let timeZoneRaw = rawStation["tz"] as? String,
                        let isBus = rawStation["bus"] as? Bool,
                        let id = rawStation["code"] as? String {
                        if let timeZone = TimeZone(identifier: timeZoneRaw) {
                            let status: AMStopStatus = {
                                switch status {
                                case "Departed":
                                    return .departed
                                case "Enroute":
                                    return .enroute
                                case "Station":
                                    return .station
                                default:
                                    return .unknown
                                }
                            }()
                            
                            let schedArrival = CRTime.amtrakAPITimeToReadableTime(string: scheduledArrivalTimeRaw, timeZone: timeZone)
                            let schedDeparture = CRTime.amtrakAPITimeToReadableTime(string: scheduledDepartureTimeRaw, timeZone: timeZone)
                            let arrival = CRTime.amtrakAPITimeToReadableTime(string: arrivalTimeRaw, timeZone: timeZone, actual: true)
                            let departure = CRTime.amtrakAPITimeToReadableTime(string: departureTimeRaw, timeZone: timeZone, actual: true)
                            
                            if [arrival, departure].contains("ALREADYHAPPEN") {
                                continue
                            }
                            
                            let stop = AMStop(name: name, id: id, timezone: timeZone, isBusStop: isBus, scheduledArrival: schedArrival, scheduledDeparture: schedDeparture, actualArrival: arrival, actualDeparture: departure, status: status)
                            stops.append(stop)
                        }
                    }
                }
                
                let train = AMTrain(trainName: trainName, trainNumber: trainNumber, trainId: trainId, location: coordinate, stops: stops, nextStationName: nextStationName, nextStationTimeZone: nextStationTimeZone, destinationStationName: destStationName, destinationStationTimezone: destStationTimeZone, hasTrainLeft: trainStateRaw == "Active", speed: speed, timeLastUpdated: timeLastUpdated)
                
                return train
            }
        }
        return nil
    }
    
    private func trak(url: URL, completion: @escaping ([String: Any]) -> Void) {
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                completion(["Error": "Request failed: \(error.localizedDescription)"])
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 502 {
                    completion([:])
                } else if response.statusCode == 503 {
                    completion([:])
                }
            }
            
            guard let data = data else {
                completion(["Error": "No data received"])
                return
            }
            
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? ["Error": "Invalid JSON"]
                completion(jsonResult)
            } catch {
                completion(["Error": "JSON parsing failed: \(error.localizedDescription)"])
            }
        }
        
        task.resume()
    }
}
