//
//  AMStation.swift
//  Cerulean
//
//  Created by WhitetailAni on 1/3/25.
//

import Foundation
import CoreLocation
import Contacts

struct AMStation {
    var name: String
    var id: String
    var timezone: TimeZone
    var location: CLLocationCoordinate2D
    var trainIds: [String]
    var hasAddress: Bool
    var address: CNMutablePostalAddress?
}
