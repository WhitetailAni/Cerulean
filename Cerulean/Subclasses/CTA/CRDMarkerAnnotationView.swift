//
//  CRDMarkerAnnotationView.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit
import MapKit
import Foundation
import SouthShoreTracker

class CRDMarkerAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        didSet { configure(for: annotation) }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = true
        print("Created new CRDMarkerAnnotationView")
        configure(for: annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for annotation: MKAnnotation?) {
        print("start")
        print(annotation.self)
        if annotation is CRDPointAnnotation {
            let annotation: CRDPointAnnotation = annotation as! CRDPointAnnotation
            if let markerTint = annotation.markerTint, let glyphTint = annotation.glyphTint {
                if let text = annotation.text {
                    glyphText = text
                    glyphTintColor = glyphTint
                    markerTintColor = markerTint
                } else if let image = annotation.image {
                    glyphImage = image
                    glyphTintColor = glyphTint
                    markerTintColor = markerTint
                }
            }
            displayPriority = .required
        }
    }
}
//thanks to https://stackoverflow.com/questions/63020138/how-to-custom-the-image-of-mkannotation-pin
