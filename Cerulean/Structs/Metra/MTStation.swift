//
//  MTStation.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/3/24.
//

import Foundation
import CoreLocation

struct MTStation {
    var supportedService: MTService
    var apiName: String
    var location: CLLocationCoordinate2D
    var accessible: Bool
    
    static func getBranch(name: String) -> MTServiceBranch {
        switch name {
        case "Prairie Street", "123rd Street/Blue Island", "119th Street/Blue Island", "115th Street/Morgan Park", "111th Street/Morgan Park", "107th Street/Beverly Hills", "103rd Street/Beverly Hills", "99th Street/Beverly Hills", "95th Street/Beverly Hills", "91st Street/Beverly Hills", "Brainerd" :
            return .beverly
        case "Blue Island", "Burr Oak", "Ashland Avenue", "Racine Avenue", "West Pullman", "Stewart Ridge", "State Street":
            return .blue_island
        case "93rd Street/South Chicago", "87th Street/South Chicago", "83rd Street", "79th Street/Cheltenham", "Windsor Park", "South Shore", "Bryn Mawr", "Stony Island":
            return .south_chicago
        default:
            return .none
        }
    }
}
