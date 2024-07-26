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
    
    init(train: CRPlacemark) {
        self.train = train
        self.station = CRPlacemark(coordinate: CLLocationCoordinate2D(latitude: 52.31697130005335, longitude: 4.746418131532647))
        super.init(frame: .zero)
    }
    
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
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park, .castle, .hospital, .library, .museum, .nationalPark, .restroom, .postOffice, .beach])
        self.isScrollEnabled = false
        self.isZoomEnabled = false
        self.isRotateEnabled = false
        self.isPitchEnabled = false
        
        if station.coordinate.latitude == 52.31697130005335 && station.coordinate.longitude == 4.746418131532647 {
            zoomMapToTrain(train: train)
        } else {
            zoomMapToTrainAndStation(train: train, station: station)
        }
    }
    
    private func zoomMapToTrain(train: CRPlacemark) {
        let trainAnnotation = MKPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "\(train.line?.textualRepresentation() ?? "Unknown") Line run \(train.trainRun ?? "000")"
        self.addAnnotation(trainAnnotation)
        
        let coordinate = train.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, 17) * Double(self.frame.size.width) / 256)
        self.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    private func zoomMapToTrainAndStation(train: CRPlacemark, station: CRPlacemark) {
        let trainAnnotation = MKPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "\(train.line?.textualRepresentation() ?? "Unknown") Line run \(train.trainRun ?? "000")"
        
        let stationAnnotation = MKPointAnnotation()
        stationAnnotation.coordinate = station.coordinate
        stationAnnotation.title = "\(station.line?.textualRepresentation() ?? "Unknown") Line stop \(station.stationName ?? "Unknown")"
        
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
