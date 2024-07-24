//
//  MapView.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import Foundation

///The class used to interface with the CTA's Train Tracker API. A new instance should be created on every request to allow for multiple concurrent requests.
class ChicagoTransitInterface: NSObject {
    @Published var requestInProgress = true
    @Published var returnedData: [String: Any] = [:]
    private let key = "e7a27d1443d8412b957e3c4ff7a655c2"
    
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
    
    func getRunNumberInfo(run: String) {
        let baseURL = "http://lapi.transitchicago.com/api/1.0/ttfollow.aspx"
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: key),
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
            URLQueryItem(name: "key", value: key),
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
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(["Error": "Request failed: \(error.localizedDescription)"])
                return
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
