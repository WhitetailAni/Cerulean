//
//  MTPlacemark.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import MapKit

class MTPlacemark: MKPlacemark, @unchecked Sendable {
    var service: MTService?
    var trainNumber: String?
    var stationName: String?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> MTPlacemark {
        let mark = MTPlacemark(coordinate: location)
        mark.service = self.service
        mark.trainNumber = self.trainNumber
        mark.stationName = self.stationName
        return mark
    }
}
