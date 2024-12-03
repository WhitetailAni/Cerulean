//
//  MTPoint.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/2/24.
//

import Foundation
import CoreLocation

struct MTPoint {
    var rawId: String
    var service: MTService
    var sequencePosition: Int
    var coordinate: CLLocationCoordinate2D
}
