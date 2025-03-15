//
//  CRPlacemark.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import MapKit

class AMPlacemark: MKPlacemark, @unchecked Sendable {
    var train: AMTrain?
    
    func placemarkWithNewLocation(_ location: CLLocationCoordinate2D) -> AMPlacemark {
        let mark = AMPlacemark(coordinate: location)
        mark.train = train
        return mark
    }
}
