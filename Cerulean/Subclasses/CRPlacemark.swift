//
//  CRPlacemark.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import MapKit

class CRPlacemark: MKPlacemark, @unchecked Sendable {
    var line: Line?
    var trainRun: String?
    var stationName: String?
}
