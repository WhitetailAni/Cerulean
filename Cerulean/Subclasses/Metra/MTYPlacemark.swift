//
//  MTPlacemark 2.swift
//  Cerulean
//
//  Created by WhitetailAni on 10/30/25.
//


//
//  MTPlacemark.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import MapKit

class MTYPlacemark: MKPlacemark, @unchecked Sendable {
    var carNumber: String?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> MTYPlacemark {
        let mark = MTYPlacemark(coordinate: location)
        mark.carNumber = self.carNumber
        return mark
    }
}
