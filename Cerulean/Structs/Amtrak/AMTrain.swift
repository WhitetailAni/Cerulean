//
//  AMTrain.swift
//  Cerulean
//
//  Created by WhitetailAni on 1/3/25.
//

import Foundation
import CoreLocation

struct AMTrain {
    var trainName: String
    var trainNumber: String
    var trainId: String
    var location: CLLocationCoordinate2D
    var stops: [AMStop]
    
    var nextStationName: String
    var nextStationTimeZone: TimeZone
    //var nextStationId: String
    
    var destinationStationName: String
    var destinationStationTimezone: TimeZone
    //var destinationStationId: String
    
    var hasTrainLeft: Bool
    var speed: Double
    var timeLastUpdated: String
}
