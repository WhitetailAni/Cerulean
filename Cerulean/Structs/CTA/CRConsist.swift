//
//  CRConsist.swift
//  Cerulean
//
//  Created by WhitetailAni on 11/29/25.
//

import Foundation
import CoreLocation

struct CRConsist {
    var location: CLLocationCoordinate2D
    var run: String
    
    static func isHoliday(run: String) -> Bool {
        return run == "1225"
    }
}
