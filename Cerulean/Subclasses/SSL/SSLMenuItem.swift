//
//  SSLMenuItem.swift
//  Cerulean
//
//  Created by WhitetailAni on 1/2/25.
//

import Foundation
import CoreLocation
import AppKit
import SouthShoreTracker

class SSLMenuItem: NSMenuItem {
    var trainNumber: String?
    var trainCoordinate: CLLocationCoordinate2D?
    
    var stop: SSLStop?
    
    var timeLastUpdated: String?
}

