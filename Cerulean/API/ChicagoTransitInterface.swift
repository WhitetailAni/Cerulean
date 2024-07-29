//
//  MapView.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import Foundation
import CoreLocation

///The class used to interface with the CTA's Train Tracker API. A new instance should be created on every request to allow for multiple concurrent requests.
class ChicagoTransitInterface: NSObject {
    let semaphore = DispatchSemaphore(value: 0)
    private let trainTrackerAPIKey = "e7a27d1443d8412b957e3c4ff7a655c2"
    private let chicagoDataPortalAppToken = "ZBIgPAfk5Mt5twmWHYWw1yDVd"
    
    ///Checks if service has ended for the day for a given CTA line
    class func hasServiceEnded(line: CRLine) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        switch line {
        case .red, .blue, .blueAlternate:
            return false
        case .brown:
            if weekday == 1 {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 40), end: CRTime(hour: 4, minute: 00))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 10), end: CRTime(hour: 4, minute: 00))
            }
        case .green, .greenAlternate:
            if weekday == 1 || weekday == 7 {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 08), end: CRTime(hour: 4, minute: 45))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 08), end: CRTime(hour: 3, minute: 45))
            }
        case .orange:
            switch weekday {
            case 1:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 34), end: CRTime(hour: 4, minute: 30))
            case 7:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 34), end: CRTime(hour: 4, minute: 00))
            default:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 34), end: CRTime(hour: 3, minute: 30))
            }
        case .pink:
            if weekday == 1 || weekday == 7 {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 31), end: CRTime(hour: 5, minute: 00))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 31), end: CRTime(hour: 4, minute: 00))
            }
        case .purple:
            switch weekday {
            case 1:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 37), end: CRTime(hour: 6, minute: 05))
            case 6:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 07), end: CRTime(hour: 4, minute: 28))
            case 7:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 2, minute: 07), end: CRTime(hour: 5, minute: 08))
            default:
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 1, minute: 27), end: CRTime(hour: 4, minute: 28))
            }
        case .yellow:
            if weekday == 1 || weekday == 7 {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 23, minute: 15), end: CRTime(hour: 6, minute: 00))
            } else {
                return CRTime.isItCurrentlyBetween(start: CRTime(hour: 23, minute: 15), end: CRTime(hour: 4, minute: 40))
            }
        }
    }
    
    ///Checks if Purple Line Express service is running
    class func isPurpleExpressRunning() -> Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return CRTime.isItCurrentlyBetween(start: CRTime(hour: 5, minute: 05), end: CRTime(hour: 10, minute: 08)) || CRTime.isItCurrentlyBetween(start: CRTime(hour: 14, minute: 18), end: CRTime(hour: 19, minute: 17)) && (weekday == 1 || weekday == 7)
    }
    
    ///Gets information about a given CTA stop ID
    func getStopCoordinateForID(id: String) -> [String: Any] {
        let baseURL = "https://data.cityofchicago.org/resource/8pix-ypme.json"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "stop_id", value: id)
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        return returnedData
    }
    
    ///Gets predictions for every station along a given train run
    func getRunNumberInfo(run: String) -> [String: Any] {
        let baseURL = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: trainTrackerAPIKey),
            URLQueryItem(name: "runnumber", value: run),
            URLQueryItem(name: "outputType", value: "JSON")
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        return returnedData
    }
    
    ///Gets a list of every run on a given CTA line
    func getRunsForLine(line: CRLine) -> [String: Any] {
        let baseURL = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx"
        var returnedData: [String: Any] = [:]
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: trainTrackerAPIKey),
            URLQueryItem(name: "rt", value: line.apiRepresentation()),
            URLQueryItem(name: "outputType", value: "JSON")
        ]
        
        contactDowntown(components: components) { result in
            returnedData = result
            self.semaphore.signal()
        }
        semaphore.wait()
        return returnedData
    }
    
    private func contactDowntown(components: URLComponents?, completion: @escaping ([String: Any]) -> Void) {
        guard let url = components?.url else {
            completion(["Error": "Invalid URL"])
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(chicagoDataPortalAppToken, forHTTPHeaderField: "X-App-Token")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(["Error": "Request failed: \(error.localizedDescription)"])
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 502 {
                    completion(["destNm": "Error", "lat":"Unable to get predictions"])
                } else if response.statusCode == 503 {
                    completion(["destNm": "Error", "lat":"Run has no predictions"])
                }
            }
            
            guard let data = data else {
                completion(["Error": "No data received"])
                return
            }
            
            do {
                if components?.queryItems?[0].name == "stop_id" {
                    let rawString = String(data: data, encoding: .utf8) ?? "[]\n"
                    let jsonString = rawString.replacingOccurrences(of: "\n", with: "")
                    
                    if let latitudeRange = jsonString.range(of: "\"latitude\":\""), let longitudeRange = jsonString.range(of: "\"longitude\":\"") {
                        let latitudeStartIndex = jsonString.index(latitudeRange.upperBound, offsetBy: 0)
                        let longitudeStartIndex = jsonString.index(longitudeRange.upperBound, offsetBy: 0)
                        
                        if let latitudeEndIndex = jsonString.range(of: "\"", range: latitudeStartIndex..<jsonString.endIndex), let longitudeEndIndex = jsonString.range(of: "\"", range: longitudeStartIndex..<jsonString.endIndex) {
                            let latitude: String = String(jsonString[latitudeStartIndex..<latitudeEndIndex.lowerBound])
                            let longitude: String = String(jsonString[longitudeStartIndex..<longitudeEndIndex.lowerBound])
                            
                            let jsonResult = ["latitude": latitude, "longitude": longitude]
                            completion(jsonResult)
                        } else {
                            completion(["Error":"Couldn't parse string to end"])
                        }
                    } else {
                        completion(["Error":"Couldn't find location info"])
                    }
                } else {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? ["Error": "Invalid JSON"]
                    completion(jsonResult)
                }
            } catch {
                completion(["Error": "JSON parsing failed: \(error.localizedDescription)"])
            }
        }
        
        task.resume()
    }
}
