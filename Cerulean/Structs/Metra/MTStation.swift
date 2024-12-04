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
}
