//
//  MapViewController.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit
import SwiftUI

class MTMapView: MKMapView {
    var train: MTPlacemark
    var station: MTPlacemark
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    
    init(train: MTPlacemark, timeLastUpdated: String) {
        self.train = train
        self.station = MTPlacemark(coordinate: CLLocationCoordinate2D(latitude: 52.31697130005335, longitude: 4.746418131532647))
        self.timeLastUpdated = timeLastUpdated
        super.init(frame: .zero)
    }
    
    init(train: MTPlacemark, station: MTPlacemark, timeLastUpdated: String) {
        self.train = train
        self.station = station
        self.timeLastUpdated = timeLastUpdated
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park, .hospital, .library, .museum, .nationalPark, .restroom, .postOffice, .beach])
        
        self.register(MTMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
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
        
        if station.coordinate.latitude == 52.31697130005335 && station.coordinate.longitude == 4.746418131532647 {
            zoomMapToTrain()
        } else {
            zoomMapToTrainAndStation()
        }
    }
    
    private func zoomMapToTrain() {
        applyLineOverlay()
        
        self.removeAnnotations(self.annotations)
        
        let trainAnnotation = MTPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "\(train.service?.fullTextualRepresentation() ?? "Unknown") train \(train.trainNumber ?? "000")"
        trainAnnotation.mark = train
        trainAnnotation.isTrainAnnotation = true
        self.addAnnotation(trainAnnotation)
        
        let coordinate = train.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 256)
        self.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    private func zoomMapToTrainAndStation() {
        applyLineOverlay()
        
        self.removeAnnotations(self.annotations)
        
        let trainAnnotation = MTPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "\(train.service?.fullTextualRepresentation() ?? "Unknown") train \(train.trainNumber ?? "000")"
        trainAnnotation.mark = train
        trainAnnotation.isTrainAnnotation = true
        
        let stationAnnotation = MTPointAnnotation()
        stationAnnotation.coordinate = station.coordinate
        stationAnnotation.title = "\(station.service?.fullTextualRepresentation() ?? "Unknown") stop \(station.stationName ?? "Unknown")"
        stationAnnotation.mark = station
        stationAnnotation.isTrainAnnotation = false
        
        self.addAnnotations([trainAnnotation, stationAnnotation])
        
        let midpointLatitude = (trainAnnotation.coordinate.latitude + stationAnnotation.coordinate.latitude) / 2
        let midpointLongitude = (trainAnnotation.coordinate.longitude + stationAnnotation.coordinate.longitude) / 2
        let midpoint = CLLocationCoordinate2D(latitude: midpointLatitude, longitude: midpointLongitude)
        let latitudeDelta = abs(trainAnnotation.coordinate.latitude - stationAnnotation.coordinate.latitude) * 1.53
        let longitudeDelta = abs(trainAnnotation.coordinate.longitude - stationAnnotation.coordinate.longitude) * 1.53
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        self.setRegion(MKCoordinateRegion(center: midpoint, span: span), animated: true)
    }
    
    private func applyLineOverlay() {
        DispatchQueue.global().async {
            let overlay = METXAPI.polyline.getPolylineForKey(key: (self.train.service?.getPolylineKey(number: self.train.trainNumber!))!)
                
            DispatchQueue.main.sync {
                self.addOverlay(overlay)
            }
        }
    }
    
    @objc func refreshTrainPosition() {
        /*DispatchQueue.global().async {
            let instance = ChicagoTransitInterface()
            let locationInfo = InterfaceResultProcessing.getLocationForRun(info: instance.getRunNumberInfo(run: self.train.trainRun ?? "000"))
            
            if locationInfo.0.latitude == -2, locationInfo.0.longitude == -3 {
                return
            }
            
            DispatchQueue.main.sync {
                self.train = self.train.placemarkWithNewLocation(locationInfo.0)
                self.timeLabel.stringValue = "Updated at \(locationInfo.1)"
                
                if self.station.coordinate.latitude == 52.31697130005335 && self.station.coordinate.longitude == 4.746418131532647 {
                    self.zoomMapToTrain()
                } else {
                    self.zoomMapToTrainAndStation()
                }
            }
        }*/
    }
}

extension MTMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MTPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = train.service?.color() ?? NSColor.black
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
