//
//  CommuterRailDivision.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/1/24.
//

import Foundation
import CoreLocation
import MapKit

class METXAPI: NSObject {
    let semaphore = DispatchSemaphore(value: 0)
    var storedPolylines: Dictionary<String, [MTPoint]> = [:]
    var storedStations: [String: [MTStation]] = [:]
    
    public static var polyline = METXAPI(polyline: true)
    public static var stations = METXAPI(stations: true)
    
    override init() {
        super.init()
    }
    
    init(polyline: Bool) {
        super.init()
        storePolylines()
    }
    
    init(stations: Bool) {
        super.init()
        storeStops()
    }
    
    func getActiveTrains() -> ([String: [MTConsist]], String) {
        var returnedData: [[String: Any]] = []
        var consistArray: [MTConsist] = []
        
        METXAPI().readGTFS(endpoint: "positions") { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        var gotTime = false
        var timeStampString = ""
        
        for rawData in returnedData {
            if let data: [String: Any] = rawData["vehicle"] as? [String: Any], let trip: [String: Any] = data["trip"] as? [String: Any], let vehicle: [String: Any] = data["vehicle"] as? [String: Any], let position: [String: Any] = data["position"] as? [String: Any], let timestamp: [String: Any] = data["timestamp"] as? [String : Any] {
                
                let trainNumber = vehicle["label"] as? String ?? "000"
                let headCarNumber = vehicle["id"] as? String ?? "0000"
                let startDateString = vehicle["start_date"] as? String ?? "19700101"
                let startTimeString = vehicle["start_time"] as? String ?? "00:00:00"
                
                if !gotTime {
                    timeStampString = CRTime.metraAPITimeToReadableTime(string: timestamp["low"] as? String ?? "1970-01-01T00:00:00.000Z")
                    gotTime = true
                }
                
                let latitude = position["latitude"] as? Double ?? 0.0
                let longitude = position["longitude"] as? Double ?? 0.0
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let heading = position["bearing"] as? Int ?? 0
                
                let serviceString = trip["route_id"] as? String ?? "SES"
                let service = MTService.init(fromAPI: serviceString)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd HH:mm:ss"
                let spinarak = "\(startDateString) \(startTimeString)"
                
                let consist = MTConsist(heading: heading, location: coordinates, trainNumber: trainNumber, headCarNumber: headCarNumber, service: service, startTime: dateFormatter.date(from: spinarak) ?? Date(timeIntervalSince1970: 0))
                
                consistArray.append(consist)
            }
        }
        
        let sortedConsists = Dictionary(grouping: consistArray) { $0.service.apiRepresentation() }
        
        var consistDict: [String: [MTConsist]] = [:]
        
        for service in MTService.allServices {
            let consistsNotSorted = sortedConsists[service.apiRepresentation()] ?? []
            
            let consists = consistsNotSorted.sorted { (top, bottom) -> Bool in
                if top.trainNumber == "RAV1" {
                    return false
                }
                if bottom.trainNumber == "RAV1" {
                    return true
                }
                
                guard let topInt = Int(top.trainNumber), let bottomInt = Int(bottom.trainNumber) else {
                    return top.trainNumber < top.trainNumber
                }
                
                return topInt < bottomInt
            }
            
            consistDict[service.apiRepresentation()] = consists
        }
        
        return (consistDict, timeStampString)
    }
    
    func getStop(service: MTService, apiName: String) -> MTStation {
        let stations = storedStations[service.apiRepresentation()] ?? []
        for station in stations {
            if station.apiName == apiName {
                return station
            }
        }
        return MTStation(supportedService: .ses, apiName: "CENTRAL", location: CLLocationCoordinate2D(latitude: 41.86833428637556, longitude: -87.62313323342718), accessible: false)
    }
    
    func storeStops() {
        var stopDict: [String: [MTStation]] = [:]
        
        readGTFS(endpoint: "schedule/stops") { result in
            var sortedByService = Dictionary(grouping: result) { entry in
                let url = entry["stop_url"] as? String ?? ""
                
                let components = url.components(separatedBy: "/")
                if let trainLinesIndex = components.firstIndex(of: "train-lines"),
                   trainLinesIndex + 1 < components.count {
                    return components[trainLinesIndex + 1]
                }
                
                return "ZONE1"
            }
            
            let zone1: [[String: Any]] = sortedByService["ZONE1"] ?? []
            
            var union: MTStation!
            var ogilvie: MTStation!
            
            var western: MTStation!
            var clybourn: MTStation!
            var rivergrove: MTStation!
            
            var prairiecrossing: MTStation!
            var joliet: MTStation!
            
            for zone1station in zone1 {
                let latitude = zone1station["stop_lat"] as? Double ?? 0.0
                let longitude = zone1station["stop_lon"] as? Double ?? 0.0
                let accessible = zone1station["wheelchair_boarding"] as? Bool ?? false
                if zone1station["stop_id"] as? String == "CUS" {
                    union = MTStation(supportedService: .ses, apiName: "CUS", location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), accessible: accessible)
                } else {
                    ogilvie = MTStation(supportedService: .ses, apiName: "OTC", location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), accessible: accessible)
                }
            }
            
            for station in sortedByService["RI"] ?? [] {
                let components = (station["stop_url"] as? String ?? "").components(separatedBy: "/")
                if components[components.count - 1] == "JOLIET" {
                    joliet = self.purifyStation(station: station)
                }
            }
            
            for station in sortedByService["MD-N"] ?? [] {
                let components = (station["stop_url"] as? String ?? "").components(separatedBy: "/")
                if components[components.count - 1] == "WESTERNAVE" {
                    western = self.purifyStation(station: station)
                } else if components[components.count - 1] == "PRAIRCROSS" {
                    prairiecrossing = self.purifyStation(station: station)
                    
                    sortedByService["MD-N"]?.removeAll(where: { $0["stop_url"] as? String == station["stop_url"] as? String })
                }
            }
            
            for station in sortedByService["UP-N"] ?? [] {
                let components = (station["stop_url"] as? String ?? "").components(separatedBy: "/")
                if components[components.count - 1] == "CLYBOURN" {
                    clybourn = self.purifyStation(station: station)
                }
            }
            
            for station in sortedByService["MD-W"] ?? [] {
                let components = (station["stop_url"] as? String ?? "").components(separatedBy: "/")
                if components[components.count - 1] == "RIVERGROVE" {
                    rivergrove = self.purifyStation(station: station)
                }
            }
            
            //joliet part of rock island
            //western ave part of md-n
            //clybourn part of up-n
            
            for service in MTService.allServices {
                let stations = sortedByService[service.apiRepresentation()] ?? []
                var stationArray: [MTStation] = []
                
                for station in stations {
                    stationArray.append(self.purifyStation(station: station))
                }
                
                switch service {
                case .up_w:
                    var ogilvie2 = ogilvie!
                    ogilvie2.supportedService = .up_w
                    stationArray.append(ogilvie2)
                case .hc:
                    var union2 = union!
                    union2.supportedService = .hc
                    var joliet2 = joliet!
                    joliet2.supportedService = .hc
                    stationArray.append(joliet2)
                    stationArray.append(union2)
                case .md_w:
                    var union2 = union!
                    union2.supportedService = .md_w
                    
                    var western2 = western!
                    western2.supportedService = .md_w
                    
                    stationArray.append(western2)
                    stationArray.append(union2)
                case .md_n:
                    var union2 = union!
                    union2.supportedService = .md_n
                    
                    stationArray.append(union2)
                case .up_nw:
                    var ogilvie2 = ogilvie!
                    ogilvie2.supportedService = .up_nw
                    
                    var clybourn2 = clybourn!
                    clybourn2.supportedService = .up_nw
                    
                    stationArray.append(clybourn2)
                    stationArray.append(ogilvie2)
                case .up_n:
                    var ogilvie2 = ogilvie!
                    ogilvie2.supportedService = .up_n
                    
                    stationArray.append(ogilvie2)
                case .bnsf:
                    var union2 = union!
                    union2.supportedService = .bnsf
                    
                    stationArray.append(union2)
                case .sws:
                    var union2 = union!
                    union2.supportedService = .sws
                    
                    stationArray.append(union2)
                case .ncs:
                    var union2 = union!
                    union2.supportedService = .ncs
                    
                    var western2 = western!
                    western2.supportedService = .ncs
                    
                    var rivergrove2 = rivergrove!
                    rivergrove2.supportedService = .ncs
                    
                    prairiecrossing.supportedService = .ncs
                    
                    stationArray.append(prairiecrossing)
                    stationArray.append(rivergrove2)
                    stationArray.append(western2)
                    stationArray.append(union2)
                case .ri, .me, .md_n, .up_n, .ses:
                    { }()
                }
                
                stopDict[service.apiRepresentation()] = stationArray
            }
            self.semaphore.signal()
        }
        semaphore.wait()
        
        storedStations = stopDict
    }
    
    private func purifyStation(station: [String: Any]) -> MTStation {
        let latitude = station["stop_lat"] as? Double ?? 0.0
        let longitude = station["stop_lon"] as? Double ?? 0.0
        let accessible = station["wheelchair_boarding"] as? Bool ?? false
        let components = (station["stop_url"] as? String ?? "").components(separatedBy: "/")
        let stationId = components[components.count - 1]
        
        let serviceString = {
            if let trainLinesIndex = components.firstIndex(of: "train-lines"),
               trainLinesIndex + 1 < components.count {
                return components[trainLinesIndex + 1]
            }
            return ""
        }()
        
        return MTStation(supportedService: MTService(fromAPI: serviceString), apiName: stationId, location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), accessible: accessible)
    }
    
    func getStopPredictions() -> [String: [MTPrediction]] {
        var predictionDict: [String: [MTPrediction]] = [:]
        
        readGTFS(endpoint: "tripUpdates") { result in
            let sortedByService = Dictionary(grouping: result) { entry in
                return ((entry["trip_update"] as? [String: Any] ?? [:])["trip"] as? [String: Any] ?? [:])["route_id"] as? String ?? "" //yea its awful cope
            }
            
            for service in MTService.allServices {
                let activeTrains = sortedByService[service.apiRepresentation()] ?? []
                
                var predictionArray: [MTPrediction] = []
                
                for activeTrain in activeTrains {
                    let tripUpdate = activeTrain["trip_update"] as? [String: Any] ?? [:]
                    if let vehicle = tripUpdate["vehicle"] as? [String: Any], let stopTimes = tripUpdate["stop_time_update"] as? [[String: Any]] {
                        
                        let trainNumber = vehicle["label"] as? String ?? "000"
                        
                        var stopArray: [MTStop] = []
                        for stop in stopTimes {
                            let position = stop["stop_sequence"] as? Int ?? 0
                            let apiName = stop["stop_id"] as? String ?? "CENTRAL"
                            let departure = stop["departure"] as? [String: Any] ?? [:]
                            let departureTimeString = (departure["time"] as? [String: Any] ?? [:])["low"] as? String ?? "19700101T00:00:00.000Z"
                            
                            let arrival = stop["arrival"] as? [String: Any] ?? [:]
                            let arrivalTimeString = (arrival["time"] as? [String: Any] ?? [:])["low"] as? String ?? "19700101T00:00:00.000Z"
                            
                            
                            
                            let departureTime = CRTime.metraAPITimeToDate(string: departureTimeString)
                            let arrivalTime = CRTime.metraAPITimeToDate(string: arrivalTimeString)
                            
                            stopArray.append(MTStop(apiName: apiName, position: position, arrivalTime: arrivalTime, departureTime: departureTime))
                        }
                        
                        predictionArray.append(MTPrediction(service: service, trainNumber: trainNumber, stops: stopArray))
                    }
                }
                
                predictionDict[service.apiRepresentation()] = predictionArray
            }
            
            self.semaphore.signal()
        }
        semaphore.wait()
        
        return predictionDict
    }
    
    func storePolylines() {
        readGTFS(endpoint: "schedule/shapes") { result in
            let sortedByService = Dictionary(grouping: result/*.filter { entry in
                guard let shapeId = entry["shape_id"] as? String else { return false }
                return !shapeId.contains("IB")
            }*/) { entry in
                return entry["shape_id"] as? String ?? ""
            }

            let superSorted = sortedByService.mapValues { entries in
                entries.compactMap { entry -> MTPoint? in
                    guard let rawId = entry["shape_id"] as? String,
                          let sequencePosition = entry["shape_pt_sequence"] as? Int,
                          let latitude = entry["shape_pt_lat"] as? Double,
                          let longitude = entry["shape_pt_lon"] as? Double else {
                        return nil
                    }
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let apiForm: String = {
                        if let obRange = rawId.range(of: "_OB") {
                            return String(rawId[..<obRange.lowerBound])
                        }
                        
                        if let ibRange = rawId.range(of: "_IB") {
                            return String(rawId[..<ibRange.lowerBound])
                        }
                        
                        return rawId
                    }()
                    
                    return MTPoint(rawId: rawId, service: MTService(fromAPI: apiForm), sequencePosition: sequencePosition, coordinate: coordinate)
                }
                .sorted { $0.sequencePosition < $1.sequencePosition }
            }
            
            self.storedPolylines = superSorted
            
            self.semaphore.signal()
        }
        semaphore.wait()
    }
    
    func getPolylineForKey(key: String, bundle: (String, MTService)) -> [MTPolyline] {
        var coordinateArray: [CLLocationCoordinate2D] = []
        
        let polyline = storedPolylines[key] ?? []
        let limit = getPolylineLimit(trainNumber: bundle.0, service: bundle.1, naturalCap: polyline.count)
        if bundle.0 == "245" {
            for i in limit..<polyline.count {
                coordinateArray.append(polyline[i].coordinate)
            }
        } else {
            for i in 0..<limit {
                coordinateArray.append(polyline[i].coordinate)
            }
        }
        
        return [MTPolyline(coordinates: coordinateArray, count: coordinateArray.count)]
    }
    
    func getPolylineLimit(trainNumber: String, service: MTService, naturalCap: Int) -> Int {
        let dest = service.getDestination(trainString: trainNumber)
        
        guard let filePath = Bundle.main.path(forResource: "limits", ofType: "plist") else {
            return naturalCap
        }
        
        let limitDict = NSDictionary(contentsOfFile: filePath) as? [String: Int] ?? [:]
        return limitDict[dest] ?? naturalCap
    }
    
    func getAllPolylines() -> [MTPolyline] {
        var array: [MTPolyline] = []
        
        storePolylines()
        
        for key in ["NCS_OB_1", "MD-W_OB_1", "SWS_OB_1", "BNSF_OB_1", "UP-NW_OB_1", "UP-NW_OB_2", "UP-N_OB_1", "MD-N_OB_1", "ME_OB_3", "ME_OB_2", "ME_OB_1", "RI_OB_1", "RI_OB_2", "UP-W_OB_1", "HC_OB_1"] {
            var coordinateArray: [CLLocationCoordinate2D] = []
            
            for point in storedPolylines[key] ?? [] {
                coordinateArray.append(point.coordinate)
            }
            
            let polyline = MTPolyline(coordinates: coordinateArray, count: coordinateArray.count)
            polyline.service = {
                switch key {
                case "MD-W_OB_1":
                    return .md_w
                case "MD-N_OB_1":
                    return .md_n
                case "UP-W_OB_1":
                    return .up_w
                case "UP-NW_OB_1", "UP-NW_OB_2":
                    return .up_nw
                case "UP-N_OB_1":
                    return .up_n
                case "SWS_OB_1":
                    return .sws
                case "BNSF_OB_1":
                    return .bnsf
                case "HC_OB_1":
                    return .hc
                case "RI_OB_1", "RI_OB_2":
                    return .ri
                case "ME_OB_1", "ME_OB_2", "ME_OB_3":
                    return .me
                case "NCS_OB_1":
                    return .ncs
                default:
                    return .ses
                }
            }()
            polyline.branch = {
                switch key {
                case "ME_OB_2":
                    return .blue_island
                case "ME_OB_3":
                    return .south_chicago
                case "RI_OB_1":
                    return .beverly
                default:
                    return MTServiceBranch.none
                }
            }()
            array.append(polyline)
        }
        
        return array
    }
    
    func readGTFS(endpoint: String, completion: @escaping ([[String: Any]]) -> Void) {
        MetworkManager.shared.contactMetra(from: "https://gtfsapi.metrarail.com/gtfs/\(endpoint)") { (data, error) in
            if let error = error {
                print("error \(error.localizedDescription)")
                return
            }
            
            if let data = data, let jsonString = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\", with: "") {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8) ?? Data(), options: []) as? [[String: Any]] ?? []
                    completion(jsonResult)
                } catch {
                    completion([["Error": "JSON parsing failed: \(error)"]])
                }
            }
        }
    }
}
