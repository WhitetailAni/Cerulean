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
    @Published var returnedData: [String: Any] = [:]
    private var requestInProgress = true
    
    class func hasServiceEnded(line: Line) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        switch line {
        case .red, .blue:
            return false
        case .brown:
            if weekday == 1 {
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 40), end: Time(hour: 4, minute: 00))
            } else {
                return Time.isItCurrentlyBetween(start: Time(hour: 2, minute: 10), end: Time(hour: 4, minute: 00))
            }
        case .green:
            if weekday == 1 || weekday == 7 {
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 08), end: Time(hour: 4, minute: 45))
            } else {
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 08), end: Time(hour: 3, minute: 45))
            }
        case .orange:
            switch weekday {
            case 1:
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 34), end: Time(hour: 4, minute: 30))
            case 7:
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 34), end: Time(hour: 4, minute: 00))
            default:
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 34), end: Time(hour: 3, minute: 30))
            }
        case .pink:
            if weekday == 1 || weekday == 7 {
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 31), end: Time(hour: 5, minute: 00))
            } else {
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 31), end: Time(hour: 4, minute: 00))
            }
        case .purple:
            switch weekday {
            case 1:
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 37), end: Time(hour: 6, minute: 05))
            case 6:
                return Time.isItCurrentlyBetween(start: Time(hour: 2, minute: 07), end: Time(hour: 4, minute: 28))
            case 7:
                return Time.isItCurrentlyBetween(start: Time(hour: 2, minute: 07), end: Time(hour: 5, minute: 08))
            default:
                return Time.isItCurrentlyBetween(start: Time(hour: 1, minute: 27), end: Time(hour: 4, minute: 28))
            }
        case .yellow:
            if weekday == 1 || weekday == 7 {
                return Time.isItCurrentlyBetween(start: Time(hour: 23, minute: 15), end: Time(hour: 6, minute: 00))
            } else {
                return Time.isItCurrentlyBetween(start: Time(hour: 23, minute: 15), end: Time(hour: 4, minute: 40))
            }
        }
    }
    
    class func isPurpleExpressRunning() -> Bool {
        return Time.isItCurrentlyBetween(start: Time(hour: 5, minute: 05), end: Time(hour: 10, minute: 08)) || Time.isItCurrentlyBetween(start: Time(hour: 2, minute: 18), end: Time(hour: 7, minute: 17))
    }
    
    ///Waits for the request to be done. This will block the current thread until it is complete.
    func wait() {
        while requestInProgress { }
    }
    
    func getStationCoordinateForID(id: String) {
        let baseURL = "https://data.cityofchicago.org/resource/8pix-ypme.json"
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "stop_id", value: id)
        ]
        
        contactDowntown(components: components) { result in
            self.returnedData = result
            self.requestInProgress = false
        }
    }
    
    func getRunNumberInfo(run: String) {
        let baseURL = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx"
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: "e7a27d1443d8412b957e3c4ff7a655c2"),
            URLQueryItem(name: "runnumber", value: run),
            URLQueryItem(name: "outputType", value: "JSON")
        ]
        
        contactDowntown(components: components) { result in
            self.returnedData = result
            self.requestInProgress = false
        }
    }
    
    func getRunsForLine(line: Line) {
        let baseURL = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx"
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: "e7a27d1443d8412b957e3c4ff7a655c2"),
            URLQueryItem(name: "rt", value: line.apiRepresentation()),
            URLQueryItem(name: "outputType", value: "JSON")
        ]
        
        contactDowntown(components: components) { result in
            self.returnedData = result
            self.requestInProgress = false
        }
    }
    
    private func contactDowntown(components: URLComponents?, completion: @escaping ([String: Any]) -> Void) {
        guard let url = components?.url else {
            completion(["Error": "Invalid URL"])
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("ZBIgPAfk5Mt5twmWHYWw1yDVd", forHTTPHeaderField: "X-App-Token")
        
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
