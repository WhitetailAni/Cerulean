//
//  CommuterRailDivision.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/1/24.
//

import Foundation
import CoreLocation


class METXAPI: NSObject {
    func readGTFS(endpoint: String, completion: @escaping ([String: Any]) -> Void) {
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: "https://gtfsapi.metrarail.com/gtfs/\(endpoint)")!)) { data, response, error in
            if let error = error {
                completion(["Error": "Request failed: \(error.localizedDescription)"])
                return
            }
            
            guard let data = data else {
                completion(["Error": "No data received"])
                return
            }
            
            print(String(data: data, encoding: .utf8))
            
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
