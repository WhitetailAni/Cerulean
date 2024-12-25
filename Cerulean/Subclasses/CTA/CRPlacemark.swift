//
//  CRPlacemark.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import MapKit

class CRPlacemark: MKPlacemark, @unchecked Sendable {
    var line: CRLine?
    var trainRun: String?
    var stationName: String?
    
    var isBrownge: Bool?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> CRPlacemark {
        let mark = CRPlacemark(coordinate: location)
        mark.line = self.line
        mark.trainRun = self.trainRun
        mark.stationName = self.stationName
        return mark
    }
}
