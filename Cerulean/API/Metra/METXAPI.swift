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
    
    public static var polyline = METXAPI(polyline: true)
    
    override init() {
        super.init()
    }
    
    init(polyline: Bool) {
        super.init()
        storePolylines()
    }
    
    func getActiveTrains() -> [MTConsist] {
        var returnedData: [[String: Any]] = []
        var consistArray: [MTConsist] = []
        
        METXAPI().readGTFS(endpoint: "positions") { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        
        for rawData in returnedData {
            if let data: [String: Any] = rawData["vehicle"] as? [String: Any], let trip: [String: Any] = data["trip"] as? [String: Any], let vehicle: [String: Any] = data["vehicle"] as? [String: Any], let position: [String: Any] = data["position"] as? [String: Any] {
                
                let trainNumber = vehicle["label"] as? String ?? "000"
                let headCarNumber = vehicle["id"] as? String ?? "0000"
                let startDateString = vehicle["start_date"] as? String ?? "19700101"
                let startTimeString = vehicle["start_time"] as? String ?? "00:00:00"
                
                let latitude = position["latitude"] as? Double ?? 0.0
                let longitude = position["longitude"] as? Double ?? 0.0
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let heading = position["bearing"] as? Int ?? 0
                
                let serviceString = trip["route_id"] as? String ?? "SES"
                let service = MTService.init(fromAPI: serviceString)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd HH:mm:ss"
                let startDateAndTimeString = "\(startDateString) \(startTimeString)"
                
                let consist = MTConsist(heading: heading, location: coordinates, trainNumber: trainNumber, headCarNumber: headCarNumber, service: service, startTime: dateFormatter.date(from: startDateAndTimeString) ?? Date(timeIntervalSince1970: 0))
                
                consistArray.append(consist)
            }
        }
        
        return consistArray
    }
    
    func getStopPredictions() {
        
    }
    
    func getPolylineForKey(key: String) -> MTPolyline {
        var coordinateArray: [CLLocationCoordinate2D] = []
        
        for point in storedPolylines[key]! {
            coordinateArray.append(point.coordinate)
        }
        
        return MTPolyline(coordinates: coordinateArray, count: coordinateArray.count)
    }
    
    func storePolylines() {
        readGTFS(endpoint: "schedule/shapes") { result in
            let sortedByService = Dictionary(grouping: result.filter { entry in
                guard let shapeId = entry["shape_id"] as? String else { return false }
                return !shapeId.contains("IB")
            }) { entry in
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
    
    func readGTFS(endpoint: String, completion: @escaping ([[String: Any]]) -> Void) {
        MetworkManager.shared.contactMetra(from: "https://gtfsapi.metrarail.com/gtfs/\(endpoint)") { (data, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let jsonString = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\", with: "") {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: []) as! [[String: Any]]
                    completion(jsonResult)
                } catch {
                    completion([["Error": "JSON parsing failed: \(error)"]])
                }
            }
        }
    }
}
