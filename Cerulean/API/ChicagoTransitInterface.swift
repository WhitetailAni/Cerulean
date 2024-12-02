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
    private let trainTrackerAPIKey = ""
    private let chicagoDataPortalAppToken = ""
    
    ///Checks if service has ended for the day for a given CTA line
    class func hasServiceEnded(line: CRLine) -> Bool {
        var weekday = Calendar.current.component(.weekday, from: Date())
        if isHoliday() {
            weekday = 1
        }
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
        case .purple, .purpleExpress:
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
        return CRTime.isItCurrentlyBetween(start: CRTime(hour: 5, minute: 05), end: CRTime(hour: 10, minute: 08)) || CRTime.isItCurrentlyBetween(start: CRTime(hour: 14, minute: 18), end: CRTime(hour: 19, minute: 17)) && !(weekday == 1 || weekday == 7 || isHoliday())
    }
    
    class private func isHoliday() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        let weekday = calendar.component(.weekday, from: today)

        if month == 1 && day == 1 {
            return true
        }

        let easterDate = calculateEasterDate(year: year)
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

    class private func calculateEasterDate(year: Int) -> Date {
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
    
    func getPolylineForLine(line: CRLine, run: Int) -> CRPolyline {
        var pointArray: [CRPoint] = []
        
        guard let filePath = Bundle.main.path(forResource: "shapes", ofType: "csv") else {
            return CRPolyline(points: [], count: 0)
        }
        
        var rawList = ""
        
        do {
            rawList = try String(contentsOfFile: filePath)
        } catch {
            print(error.localizedDescription)
            return CRPolyline(points: [], count: 0)
        }
        
        var rows = rawList.components(separatedBy: "\n")
        rows.removeFirst()
        
        for i in 0..<rows.count {
            let columns = rows[i].split(separator: ",")
            if columns.count > 0 {
                let id = Int(columns[0])!
                if id > 308000000 {
                    if ![308400053, 308500129, 308500007, 308500038, 308500029, 308500008, 308500012, 308500001, 308400036, 308500022, 308500039, 308500040].contains(id) {
                        pointArray.append(CRPoint(routeId: Int(columns[0])!, coordinate: CLLocationCoordinate2D(latitude: Double(columns[1])!, longitude: Double(columns[2])!), sequencePosition: Int(columns[3])!))
                    }
                }
            }
        }
        let sorted = Dictionary(grouping: pointArray) { $0.routeId }
        let extraSorted = sorted.mapValues { route in
            route.sorted { $0.sequencePosition < $1.sequencePosition }
        }
        
        let desiredId = CRLine.gtfsIDForLineAndRun(line: line, run: run)
        let pojntArray: [CRPoint] = extraSorted[desiredId]!
        var coordinateArray: [CLLocationCoordinate2D] = []
        for pojnt in pojntArray {
            coordinateArray.append(pojnt.coordinate)
        }
        let overlay = CRPolyline(coordinates: coordinateArray, count: coordinateArray.count)
        overlay.line = line
        
        return overlay
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
