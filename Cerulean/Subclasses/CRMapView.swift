//
//  MapViewController.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit

class CRMapView: MKMapView {
    var train: CRPlacemark
    var station: CRPlacemark
    
    init(train: CRPlacemark, station: CRPlacemark) {
        self.train = train
        self.station = station
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
    }
    
    private func zoomToAnnotations(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
            if zoomRect.isNull {
                zoomRect = pointRect
            } else {
                zoomRect = zoomRect.union(pointRect)
            }
        }
        self.setVisibleMapRect(zoomRect, edgePadding: NSEdgeInsets(top: 35, left: 35, bottom: 100, right: 35), animated: true)
    }
    
    private func plotPolylineAndTrainAndZoomMap(train: CRPlacemark, station: CRPlacemark) {
        let trainAnnotation = MKPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "\(train.line?.textualRepresentation() ?? "Unknown") Line run \(train.trainRun ?? "000")"
        
        let stationAnnotation = MKPointAnnotation()
        stationAnnotation.coordinate = train.coordinate
        stationAnnotation.title = "\(train.line?.textualRepresentation() ?? "Unknown") Line stop \(train.stationName ?? "Unknown")"
        
        var annotations: [any MKAnnotation] = [trainAnnotation, stationAnnotation]
        
        self.addAnnotations(annotations)
        
        self.zoomToAnnotations(annotations: annotations)
    }
}
