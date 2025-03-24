//
//  MTStop.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/3/24.
//

import Foundation

struct MTStop {
    var apiName: String
    var position: Int
    var arrivalTime: Date
    var departureTime: Date
    
    static func purifyApiName(name: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "stops", ofType: "plist") else {
            return name
        }
        
        #warning("missing ravinia park")
        let dict = NSDictionary(contentsOfFile: filePath) as? [String: String] ?? [:]
        return dict[name] ?? name
    }
}
