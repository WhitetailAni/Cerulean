//
//  CRMarkerAnnotationView.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit
import MapKit
import Foundation
import SouthShoreTracker

class SSLMarkerAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet { configure(for: annotation) }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure(for: annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for annotation: MKAnnotation?) {
        if annotation is SSLPointAnnotation {
            let annotation: SSLPointAnnotation = annotation as! SSLPointAnnotation
            if let train = annotation.mark?.trainNumber {
                markerTintColor = SSLTracker.colors.maroon
                glyphTintColor = SSLTracker.colors.beige
                glyphText = train
            } else if annotation.mark?.stationName != nil {
                glyphImage = .ssl2
                markerTintColor = SSLTracker.colors.maroon
                glyphTintColor = SSLTracker.colors.beige
            }
            displayPriority = .required
        }
    }
}
//thanks to https://stackoverflow.com/questions/63020138/how-to-custom-the-image-of-mkannotation-pin
