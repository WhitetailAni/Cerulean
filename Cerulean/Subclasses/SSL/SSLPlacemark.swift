//
//  CRPlacemark.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import MapKit

import SouthShoreTracker

class SSLPlacemark: MKPlacemark, @unchecked Sendable {
    var trainNumber: String?
    var stationName: String?
    var endStop: SSLStop?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> SSLPlacemark {
        let mark = SSLPlacemark(coordinate: location)
        mark.trainNumber = self.trainNumber
        mark.stationName = self.stationName
        return mark
    }
}
