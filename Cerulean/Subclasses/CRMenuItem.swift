//
//  CRMenuItem.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import CoreLocation

class CRMenuItem: NSMenuItem {
    var trainLine: Line?
    var trainRun: String?
    var trainCoordinate: CLLocationCoordinate2D?
    var trainDesiredStop: String?
    var trainDesiredStopID: String?
}

