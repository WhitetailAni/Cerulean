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
