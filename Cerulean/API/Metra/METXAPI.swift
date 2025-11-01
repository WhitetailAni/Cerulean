//
//  CommuterRailDivision.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/1/24.
//

import Foundation
import CoreLocation
import MapKit
import GTFS

class METXAPI: NSObject {
    let semaphore = DispatchSemaphore(value: 0)
    var storedPolylines: Dictionary<String, [MTPoint]> = [:]
    var storedStations: [String: [MTStation]] = [:]
    var apiKey = 
    
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
        var returnedData: [String: Any] = [:]
        var consistArray: [MTConsist] = []
        
        METXAPI().readGTFS(endpoint: "positions") { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        var timeStampString = "joe biden o' clock"
        if let header = returnedData["header"] as? [String: Any], let timestampRaw = header["timestamp"] as? String, let timestamp = Double(timestampRaw) {
            timeStampString = CRTime.unixTimestampToReadableTime(timestamp: timestamp)
        }
        
        if let returnedArray = returnedData["entity"] as? [[String: Any]] {
            for rawData in returnedArray {
                if let data = rawData["vehicle"] as? [String: Any], let vehicle = data["vehicle"] as? [String: Any], let position = data["position"] as? [String: Any], let trip = data["trip"] as? [String: Any] {
                    if let carNumber = vehicle["id"] as? String, let trainNumber = vehicle["label"] as? String, let railLine = trip["routeId"] as? String, let latitude = position["latitude"] as? Double, let longitude = position["longitude"] as? Double {
                        
                        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let service = MTService.init(fromAPI: railLine)
                        
                        let consist = MTConsist(trainNumber: trainNumber, headCarNumber: carNumber, location: coordinates, service: service)
                        consistArray.append(consist)
                    }
                }
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
    
    func getYardTrains() -> ([MTYardConsist], String) {
        var returnedData: [String: Any] = [:]
        var consistArray: [MTYardConsist] = []
        
        METXAPI().readGTFS(endpoint: "positions") { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        var timeStampString = "joe biden o' clock"
        if let header = returnedData["header"] as? [String: Any], let timestampRaw = header["timestamp"] as? String, let timestamp = Double(timestampRaw) {
            timeStampString = CRTime.unixTimestampToReadableTime(timestamp: timestamp)
        }
        
        if let returnedArray = returnedData["entity"] as? [[String: Any]] {
            for rawData in returnedArray {
                if let data = rawData["vehicle"] as? [String: Any], let vehicle = data["vehicle"] as? [String: Any], let position = data["position"] as? [String: Any], data["trip"] == nil {
                    if let carNumber = vehicle["id"] as? String, let latitude = position["latitude"] as? Double, let longitude = position["longitude"] as? Double {
                        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        
                        let consist = MTYardConsist(headCarNumber: carNumber, location: coordinates)
                        consistArray.append(consist)
                    }
                }
            }
        }
        return (consistArray, timeStampString)
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
        
        guard let filePath = Bundle.main.path(forResource: "metra_stops", ofType: "csv") else {
            return
        }
        
        var result = ""
        do {
            result = try String(contentsOfFile: filePath)
        } catch {
            print(error.localizedDescription)
            return
        }

        var rows = result.components(separatedBy: "\r\n")
        rows.removeFirst()
        
        var sortedByService: [String: [MTStation]] = [:]
        
        for i in 0..<rows.count {
            let columns = rows[i].split(separator: ",")
            if columns.count > 0 && columns[6].components(separatedBy: "/").count > 5 {
                let service = columns[6].components(separatedBy: "/")[5]
                let station = MTStation(supportedService: MTService(fromAPI: service), apiName: String(columns[0]), location: CLLocationCoordinate2D(latitude: Double(columns[3]) ?? 0, longitude: Double(columns[4]) ?? 0), accessible: (Int(columns[7]) == 1))
                
                if sortedByService[service] == nil {
                    sortedByService[service] = []
                }
                sortedByService[service]?.append(station)
            }
        }
        
        var union: MTStation!
        var ogilvie: MTStation!
        
        var western: MTStation!
        var clybourn: MTStation!
        var rivergrove: MTStation!
        
        var prairiecrossing: MTStation!
        var joliet: MTStation!
        
        for station in sortedByService["ZONE1"] ?? [] {
            if station.apiName == "CUS" {
                union = station
            } else if station.apiName == "OTC" {
                ogilvie = station
            }
        }
        
        for station in sortedByService["RI"] ?? [] {
            if station.apiName == "JOLIET" {
                joliet = station
            }
        }
        
        for station in sortedByService["MD-N"] ?? [] {
            if station.apiName == "WESTERNAVE" {
                western = station
            } else if station.apiName == "PRAIRCROSS" {
                prairiecrossing = station
                
                //sortedByService["MD-N"]?.removeAll(where: { $0["stop_url"] as? String == station["stop_url"] as? String })
            }
        }
        
        for station in sortedByService["UP-N"] ?? [] {
            if station.apiName == "CLYBOURN" {
                clybourn = station
            }
        }
        
        for station in sortedByService["MD-W"] ?? [] {
            if station.apiName == "RIVERGROVE" {
                rivergrove = station
            }
        }
        
        //joliet part of rock island
        //western ave part of md-n
        //clybourn part of up-n
        
        for service in MTService.allServices {
            let stations = sortedByService[service.apiRepresentation()] ?? []
            var stationArray: [MTStation] = []
            
            for station in stations {
                stationArray.append(station)
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
            case .ri, .me, .ses:
                { }()
            }
            
            stopDict[service.apiRepresentation()] = stationArray
        }
        
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
    
    func getStopPredictions() -> [String: MTPrediction] {
        var returnedData: [[String: Any]] = []
        
        var predictionDict: [String: MTPrediction] = [:]
        
        readGTFS(endpoint: "tripupdates") { result in
            if let data = result["entity"] as? [[String: Any]] {
                returnedData = data
            }
            
            self.semaphore.signal()
        }
        semaphore.wait()
        
        for data in returnedData {
            let tripUpdate = data["tripUpdate"] as? [String: Any] ?? [:]
            if let vehicle = tripUpdate["vehicle"] as? [String: Any], let stopTimes = tripUpdate["stopTimeUpdate"] as? [[String: Any]], let trainNumber = vehicle["label"] as? String, let routeId = (tripUpdate["trip"] as? [String: Any])?["routeId"] as? String {
                
                var stopArray: [MTStop] = []
                for stop in stopTimes {
                    if let position = stop["stopSequence"] as? Int, let apiName = stop["stopId"] as? String, let arrival = stop["arrival"] as? [String: Any], let arrivalTimestring = arrival["time"] as? String, let arrivalTimestamp = Double(arrivalTimestring) {
                        stopArray.append(MTStop(apiName: apiName, position: position, arrivalTime: Date(timeIntervalSince1970: arrivalTimestamp)))
                    }
                }
                
                predictionDict[trainNumber] = MTPrediction(service: MTService(fromAPI: routeId), trainNumber: trainNumber, stops: stopArray)
            }
        }
        
        return predictionDict
    }
    
    func storePolylines() {
        guard let filePath = Bundle.main.path(forResource: "metra_shapes", ofType: "csv") else {
            return
        }
        
        var result = ""
        
        do {
            result = try String(contentsOfFile: filePath)
        } catch {
            print(error.localizedDescription)
            return
        }

        var rows = result.components(separatedBy: "\r\n")
        rows.removeFirst()
        
        for i in 0..<rows.count {
            let columns = rows[i].split(separator: ",")
            if columns.count > 0 {
                let currentOverlay = String(columns[0])
                let point = MTPoint(rawId: currentOverlay, service: MTService(fromAPI: currentOverlay.components(separatedBy: "_").first ?? "SES"), sequencePosition: Int(columns[3]) ?? 0, coordinate: CLLocationCoordinate2D(latitude: Double(columns[1]) ?? 0, longitude: Double(columns[2]) ?? 0))
                if storedPolylines[currentOverlay] == nil {
                    storedPolylines[currentOverlay] = []
                }
                storedPolylines[currentOverlay]?.append(point)
            }
        }
    }
    
    func getPolylineForKey(key: String, bundle: (String, MTService)) -> [MTPolyline] {
        var coordinateArray: [CLLocationCoordinate2D] = []
        
        let polyline = storedPolylines[key] ?? []
        let limit = getPolylineLimit(trainNumber: bundle.0, service: bundle.1, naturalCap: polyline.count)
        if bundle.0 == "245" {
            for i in limit..<polyline.count {
                coordinateArray.append(polyline[i].coordinate)
            }
        } else if ["ME_IB_2", "ME_OB_2"].contains(key) {
            for element in polyline {
                coordinateArray.append(element.coordinate)
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
    
    private func readGTFS(endpoint: String, completion: @escaping ([String: Any]) -> Void) {
        guard let url = URL(string: "https://gtfspublic.metrarr.com/gtfs/public/\(endpoint)?api_token=\(apiKey)") else {
            completion(["Error": "Invalid URL"])
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(["Error": "Request failed: \(error.localizedDescription)"])
                return
            }
            
            guard let data = data else {
                completion(["Error": "No data received"])
                return
            }
            
            do {
                let jsonString = try TransitRealtime_FeedMessage(serializedBytes: data) //new metra api only returns protobuf, but thats no good for swift
                let jsonResult = try JSONSerialization.jsonObject(with: jsonString.jsonUTF8Bytes(), options: []) as? [String: Any] ?? ["Error": "Invalid JSON"] //so we convert it back to json LOL (old api returned json - it was a little broken, but it was json)
                completion(jsonResult)
            } catch {
                completion(["Error": "JSON parsing failed: \(error.localizedDescription)"])
            }
        }
        
        task.resume()
    }
}
