//
//  CRDMapView.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit
import SwiftUI
import SouthShoreTracker

class CRDMapView: MKMapView {
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    var annotes: [CRDPointAnnotation] = []
    
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
        
        self.delegate = self
        print("Delegate set to: \(String(describing: self.delegate))")
        self.register(CRDMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        timeLabel = NSTextField(labelWithString: "Updated at \(timeLastUpdated)")
        timeLabel.font = NSFont.systemFont(ofSize: 12)
        timeLabel.textColor = NSColor(r: 222, g: 222, b: 222)
        timeLabel.isBezeled = false
        timeLabel.drawsBackground = false
        timeLabel.isEditable = false
        timeLabel.sizeToFit()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(timeLabel)
        
        let testAnnotation = CRDPointAnnotation()
            testAnnotation.coordinate = CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298) // Chicago coordinates
            testAnnotation.markerTint = .red
            testAnnotation.text = "TEST"
        
        self.addAnnotation(testAnnotation)
        
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
            applyCTAOverlay(line: line, run: "001")
        }
        applyCTAOverlay(line: .greenAlternate, run: "001")
        
        DispatchQueue.global().async {
            var overlayArray: [MKOverlay] = [SSLTracker().getOverlay()]
            let pverlays = METXAPI().getAllPolylines()
            for pverlay in pverlays {
                overlayArray.append(pverlay)
            }
                
            DispatchQueue.main.sync {
                self.addOverlays(overlayArray)
            }
        }
        
        self.annotes = []
        self.removeAnnotations(self.annotations)
        
        let marksTwo = refreshCTAPosition()
        let marksThree = refreshMetraPosition()
        let marksFour = refreshSSLPosition()
        
        let marksNine = marksTwo + marksThree + marksFour
        
        self.addAnnotations(annotes)
        
        zoomToTrains(marksNine)
    }
    
    private func applyCTAOverlay(line: CRLine, run: String) {
        DispatchQueue.global().async {
            var overlayArray: [MKOverlay] = []
            
            let overlay: CRPolyline = ChicagoTransitInterface.polyline.getPolylineForLine(line: line, run: Int(run) ?? 000)
            overlayArray.append(overlay)
            
            DispatchQueue.main.sync {
                self.addOverlays(overlayArray)
            }
        }
    }
    
    private func zoomToTrains(_ placemarks: [MKPlacemark]) {
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
    
    @objc func refreshTrainPosition() {
        refreshCTAPosition()
        refreshMetraPosition()
        refreshSSLPosition()
    }
    
    @discardableResult func refreshCTAPosition() -> [CRPlacemark] {
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
        
        for annotation in annotationArray {
            var annote = CRDPointAnnotation()
            annote.mark = annotation.mark
            if let line = annotation.mark?.line {
                if let run = annotation.mark?.trainRun {
                    if line == .blueAlternate || line == .greenAlternate {
                        annote.markerTint = .white
                        annote.text = run
                        annote.glyphTint = line.color()
                    } else {
                        annote.markerTint = line.color()
                        annote.text = run
                    }
                } else if let stationName = annotation.mark?.stationName {
                    annote.image = .ctaTrain
                    if stationName == "King Drive" || stationName == "Cottage Grove" {
                        annote.glyphTint = CRLine.green.color()
                        annote.markerTint = .white
                    } else {
                        annote.markerTint = line.color()
                    }
                }
            }
            
            annotes.append(annote)
        }
        
        return markArray
    }
    
    @discardableResult func refreshMetraPosition() -> [MTPlacemark] {
        let consistDict = METXAPI().getActiveTrains()
        var marks: [MTPlacemark] = []
        var annotationArray: [MTPointAnnotation] = []
        
        for collection in consistDict.0 {
            let service = MTService(fromAPI: collection.key)
            
            for consist in collection.value {
                let mark = MTPlacemark(coordinate: consist.location)
                mark.service = service
                
                let annote = MTPointAnnotation()
                annote.mark = mark
                annote.service = service
                
                marks.append(mark)
                annotationArray.append(annote)
            }
        }
        
        for annotation in annotationArray {
            var annote = CRDPointAnnotation()
            annote.mark = annotation.mark
            
            if let service = annotation.mark?.service {
                if let train = annotation.mark?.trainNumber {
                    annote.markerTint = service.color(branch: service.getBranch(trainString: train))
                    annote.text = train
                } else if let stationName = annotation.mark?.stationName {
                    annote.image = .metra
                    annote.markerTint = service.color(branch: MTStation.getBranch(name: stationName))
                }
            }
            
            annotes.append(annote)
        }
        
        return marks
    }
    
    @discardableResult func refreshSSLPosition() -> [SSLPlacemark] {
        let vehicles = SSLTracker().getVehicles()
        var marks: [SSLPlacemark] = []
        var annotationArray: [SSLPointAnnotation] = []
        
        for vehicle in vehicles {
            let mbrk = SSLPlacemark(coordinate: vehicle.location)
            marks.append(mbrk)
            let annote = SSLPointAnnotation()
            annote.mark = mbrk
            annotationArray.append(annote)
        }
        
        for annotation in annotationArray {
            var annote = CRDPointAnnotation()
            annote.mark = annotation.mark
            
            if let train = annotation.mark?.trainNumber {
                annote.markerTint = SSLTracker.colors.maroon
                annote.glyphTint = SSLTracker.colors.beige
                annote.text = train
            } else if annotation.mark?.stationName != nil {
                annote.markerTint = SSLTracker.colors.maroon
                annote.glyphTint = SSLTracker.colors.beige
            }
            
            annotes.append(annote)
        }
        
        return marks
    }
}

extension CRDMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? CRPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = polyline.line?.color()
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        } else if let polyline = overlay as? MTPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = polyline.service?.color(branch: polyline.branch!)
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        } else if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = SSLTracker.colors.beige
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("Requesting view for annotation: \(annotation)")
        
        guard let pointAnnotation = annotation as? CRDPointAnnotation else {
            print("Not a CRDPointAnnotation")
            return nil
        }
        
        let identifier = "CRDMarkerAnnotationView"
        var view: CRDMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CRDMarkerAnnotationView {
            view = dequeuedView
        } else {
            view = CRDMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        // Force configure the view here
        view.configure(for: pointAnnotation)
        return view
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("Map finished loading")
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("Added \(views.count) annotation views")
    }
}
