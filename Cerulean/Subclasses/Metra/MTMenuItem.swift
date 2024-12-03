//
//  CRMenuItem.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import CoreLocation

class MTMenuItem: NSMenuItem {
    var service: MTService?
    
    var trainNumber: String?
    var trainCoordinate: CLLocationCoordinate2D?
    
    var trainDesiredStop: String?
    var trainDesiredStopID: String?
    
    var timeLastUpdated: String?
    
    var linkToOpen: URL?
}

