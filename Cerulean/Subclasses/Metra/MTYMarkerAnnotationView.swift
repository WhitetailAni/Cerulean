//
//  MTMarkerAnnotationView 2.swift
//  Cerulean
//
//  Created by WhitetailAni on 10/30/25.
//

import AppKit
import MapKit
import Foundation

class MTYMarkerAnnotationView: MKMarkerAnnotationView {
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
        if annotation is MTYPointAnnotation {
            let annotation: MTYPointAnnotation = annotation as! MTYPointAnnotation
            if let carNumber = annotation.mark?.carNumber {
                glyphText = carNumber
                glyphTintColor = NSColor(r: 255, g: 255, b: 255)
                markerTintColor = NSColor(r: 2, g: 83, b: 164)
            }
            displayPriority = .required
        }
    }
}
//thanks to https://stackoverflow.com/questions/63020138/how-to-custom-the-image-of-mkannotation-pin
