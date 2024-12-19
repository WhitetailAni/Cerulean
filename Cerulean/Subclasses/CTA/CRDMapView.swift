//
//  MapViewController.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit
import SwiftUI

class CRDMapView: MKMapView {
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    
    init(timeLastUpdated: String) {
        self.timeLastUpdated = timeLastUpdated
        super.init(frame: .zero)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park, .hospital, .library, .museum, .nationalPark, .restroom, .postOffice, .beach])
        
        self.register(CRMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        self.delegate = self
        
        timeLabel = NSTextField(labelWithString: "Updated at \(timeLastUpdated)")
        timeLabel.font = NSFont.systemFont(ofSize: 12)
        timeLabel.textColor = NSColor(r: 222, g: 222, b: 222)
        timeLabel.isBezeled = false
        timeLabel.drawsBackground = false
        timeLabel.isEditable = false
        timeLabel.sizeToFit()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
        
        let refreshButton = NSButton(image: NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)!, target: self, action: #selector(refreshTrainPosition))
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.mapType = .mutedStandard
        
        self.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            refreshButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            refreshButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
        ])
        
        zoomMap()
    }
    
    private func zoomMap() {
        for line in CRLine.allLines {
            applyLineOverlay(line: line, run: "001")
        }
        applyLineOverlay(line: .greenAlternate, run: "001")
        
        self.removeAnnotations(self.annotations)
        
        let marksTwo = refreshTrainPosition()
        
        zoomToTrains(marksTwo)
    }
    
    private func applyLineOverlay(line: CRLine, run: String) {
        DispatchQueue.global().async {
            var overlayArray: [MKOverlay] = []
            
            let overlay: CRPolyline = ChicagoTransitInterface.polyline.getPolylineForLine(line: line, run: Int(run) ?? 000)
            overlayArray.append(overlay)
            
            DispatchQueue.main.sync {
                self.addOverlays(overlayArray)
            }
        }
    }
    
    private func zoomToTrains(_ placemarks: [CRPlacemark]) {
       let coordinates = placemarks.map { $0.coordinate }
       
       let totalLat = coordinates.reduce(0) { $0 + $1.latitude }
       let totalLong = coordinates.reduce(0) { $0 + $1.longitude }
       let midpointLat = totalLat / Double(coordinates.count)
       let midpointLong = totalLong / Double(coordinates.count)
       let midpoint = CLLocationCoordinate2D(latitude: midpointLat, longitude: midpointLong)
       
       var maxLatDelta: CLLocationDegrees = 0
       var maxLongDelta: CLLocationDegrees = 0
       
       for i in 0..<coordinates.count {
           for j in (i+1)..<coordinates.count {
               let latDelta = abs(coordinates[i].latitude - coordinates[j].latitude)
               let lonDelta = abs(coordinates[i].longitude - coordinates[j].longitude)
               
               maxLatDelta = max(maxLatDelta, latDelta)
               maxLongDelta = max(maxLongDelta, lonDelta)
           }
       }
       
       let span = MKCoordinateSpan(
           latitudeDelta: maxLatDelta * 1.53,
           longitudeDelta: maxLongDelta * 1.53
       )
       
        self.setRegion(MKCoordinateRegion(center: midpoint, span: span), animated: true)
    }
    
    @discardableResult @objc func refreshTrainPosition() -> [CRPlacemark] {
        self.removeAnnotations(self.annotations)
        
        var annotationArray: [CRPointAnnotation] = []
        var markArray: [CRPlacemark] = []
        
        for line in CRLine.allLines {
            let info = ChicagoTransitInterface().getRunsForLine(line: line)
            let runs = InterfaceResultProcessing.debugCleanUpRunInfo(info: info)
            
            for run in runs {
                if run.coordinate.latitude != 0.0 && run.coordinate.longitude != 0.0 {
                    let mark = CRPlacemark(coordinate: run.coordinate)
                    mark.trainRun = run.run
                    var line2: CRLine = line
                    if run.terminus == "Cottage Grove" {
                        line2 = .greenAlternate
                    } else if run.terminus == "UIC-Halsted" {
                        line2 = .blueAlternate
                    }
                    mark.line = line2
                    
                    let annotation = CRPointAnnotation()
                    annotation.coordinate = run.coordinate
                    annotation.title = ""
                    annotation.mark = mark
                    
                    annotationArray.append(annotation)
                    markArray.append(mark)
                }
            }
        }
        
        self.addAnnotations(annotationArray)
        
        return markArray
    }
}

extension CRDMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? CRPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = polyline.line?.color()
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
