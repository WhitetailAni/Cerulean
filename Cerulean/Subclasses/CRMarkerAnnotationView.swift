//
//  CRMarkerAnnotationView.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit
import MapKit
import Foundation

class CRMarkerAnnotationView: MKMarkerAnnotationView {
    
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
        if annotation is CRPointAnnotation {
            let annotation: CRPointAnnotation = annotation as! CRPointAnnotation
            if let line = annotation.mark?.line {
                if let run = annotation.mark?.trainRun {
                    if line == .blueAlternate || line == .greenAlternate {
                        markerTintColor = .white
                        glyphText = run
                        glyphTintColor = line.color()
                    } else {
                        markerTintColor = line.color()
                        glyphText = run
                    }
                } else if let stationName = annotation.mark?.stationName {
                    glyphImage = .ctaTrain
                    if stationName == "King Drive" || stationName == "Cottage Grove" {
                        glyphTintColor = CRLine.green.color()
                        markerTintColor = .white
                    } else {
                        markerTintColor = line.color()
                    }
                }
                displayPriority = .required
            }
        }
    }
}
//thanks to https://stackoverflow.com/questions/63020138/how-to-custom-the-image-of-mkannotation-pin
