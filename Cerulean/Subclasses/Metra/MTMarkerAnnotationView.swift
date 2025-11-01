//
//  CRMarkerAnnotationView.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit
import MapKit
import Foundation

class MTMarkerAnnotationView: MKMarkerAnnotationView {
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
        if annotation is MTPointAnnotation {
            let annotation: MTPointAnnotation = annotation as! MTPointAnnotation
            if let service = annotation.mark?.service {
                if let train = annotation.mark?.trainNumber {
                    glyphText = train
                    glyphTintColor = service.textColor(branch: service.getBranch(trainString: train))
                    markerTintColor = service.color(branch: service.getBranch(trainString: train))
                } else if let stationName = annotation.mark?.stationName {
                    glyphImage = .metraM
                    glyphTintColor = service.textColor(branch: MTStation.getBranch(name: stationName))
                    markerTintColor = service.color(branch: MTStation.getBranch(name: stationName))
                }
                displayPriority = .required
            }
        }
    }
}
//thanks to https://stackoverflow.com/questions/63020138/how-to-custom-the-image-of-mkannotation-pin
