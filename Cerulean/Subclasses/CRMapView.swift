//
//  MapViewController.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit
import SwiftUI

class CRMapView: MKMapView {
    var train: CRPlacemark
    var station: CRPlacemark
    var timeLastUpdated: String
    
    init(train: CRPlacemark, timeLastUpdated: String) {
        self.train = train
        self.station = CRPlacemark(coordinate: CLLocationCoordinate2D(latitude: 52.31697130005335, longitude: 4.746418131532647))
        self.timeLastUpdated = timeLastUpdated
        super.init(frame: .zero)
    }
    
    init(train: CRPlacemark, station: CRPlacemark, timeLastUpdated: String) {
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
        
        self.register(CRMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        let timeLabel = NSTextField(labelWithString: "Updated at \(timeLastUpdated)")
        timeLabel.font = NSFont.systemFont(ofSize: 12)
        timeLabel.textColor = NSColor(r: 222, g: 222, b: 222)
        timeLabel.isBezeled = false
        timeLabel.drawsBackground = false
        timeLabel.isEditable = false
        timeLabel.sizeToFit()
        
        self.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
        
        if station.coordinate.latitude == 52.31697130005335 && station.coordinate.longitude == 4.746418131532647 {
            zoomMapToTrain(train: train)
        } else {
            zoomMapToTrainAndStation(train: train, station: station)
        }
    }
    
    private func zoomMapToTrain(train: CRPlacemark) {
        
        let trainAnnotation = CRPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "\(train.line?.textualRepresentation() ?? "Unknown") Line run \(train.trainRun ?? "000")"
        trainAnnotation.mark = train
        self.addAnnotation(trainAnnotation)
        
        let coordinate = train.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 256)
        self.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    private func zoomMapToTrainAndStation(train: CRPlacemark, station: CRPlacemark) {
        let trainAnnotation = CRPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "\(train.line?.textualRepresentation() ?? "Unknown") Line run \(train.trainRun ?? "000")"
        trainAnnotation.mark = train
        
        let stationAnnotation = CRPointAnnotation()
        stationAnnotation.coordinate = station.coordinate
        stationAnnotation.title = "\(station.line?.textualRepresentation() ?? "Unknown") Line stop \(station.stationName ?? "Unknown")"
        stationAnnotation.mark = station
        
        self.addAnnotations([trainAnnotation, stationAnnotation])
        
        let midpointLatitude = (trainAnnotation.coordinate.latitude + stationAnnotation.coordinate.latitude) / 2
        let midpointLongitude = (trainAnnotation.coordinate.longitude + stationAnnotation.coordinate.longitude) / 2
        let midpoint = CLLocationCoordinate2D(latitude: midpointLatitude, longitude: midpointLongitude)
        let latitudeDelta = abs(trainAnnotation.coordinate.latitude - stationAnnotation.coordinate.latitude) * 1.53
        let longitudeDelta = abs(trainAnnotation.coordinate.longitude - stationAnnotation.coordinate.longitude) * 1.53
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        self.setRegion(MKCoordinateRegion(center: midpoint, span: span), animated: true)
    }
}
