//
//  AMStation.swift
//  Cerulean
//
//  Created by WhitetailAni on 1/3/25.
//

import Foundation

struct AMStop {
    var name: String
    var id: String
    var timezone: TimeZone
    var isBusStop: Bool
    var scheduledArrival: String
    var scheduledDeparture: String
    var actualArrival: String
    var actualDeparture: String
    var status: AMStopStatus
}

enum AMStopStatus {
    case enroute
    case station
    case departed
    case unknown
}
