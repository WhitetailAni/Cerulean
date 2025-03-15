//
//  MapViewController.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit
import MapKit
import SwiftUI
import SouthShoreTracker

class AMMapView: MKMapView {
    var train: AMPlacemark
    var station: AMPlacemark
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    
    init(train: AMPlacemark, timeLastUpdated: String) {
        self.train = train
        self.station = AMPlacemark(coordinate: CLLocationCoordinate2D(latitude: 52.31697130005335, longitude: 4.746418131532647))
        self.timeLastUpdated = timeLastUpdated
        super.init(frame: .zero)
    }
    
    init(train: AMPlacemark, station: AMPlacemark, timeLastUpdated: String) {
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
        
        self.register(AMMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
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
        
        let trainAnnotation = AMPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "Train \(train.train?.trainNumber ?? "000")"
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
        
        let trainAnnotation = AMPointAnnotation()
        trainAnnotation.coordinate = train.coordinate
        trainAnnotation.title = "Train \(train.train?.trainNumber ?? "000")"
        trainAnnotation.mark = train
        trainAnnotation.isTrainAnnotation = true
        
        let stationAnnotation = AMPointAnnotation()
        /*stationAnnotation.coordinate = station.coordinate
        stationAnnotation.title = station.stationName
        stationAnnotation.mark = station
        stationAnnotation.isTrainAnnotation = false*/
        
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
            let overlayTable = Amtraker.polyline.polylines
            
            print(overlayTable.keys)
            print(overlayTable["6"])
            
            if let array = overlayTable[self.train.train?.trainNumber ?? "7"] {
                print(array.count)
                let overlay = MKPolyline(coordinates: array, count: array.count)
                
                DispatchQueue.main.sync {
                    self.addOverlay(overlay)
                }
            } else {
                print("shitfuck")
            }
        }
    }
    
    @objc func refreshTrainPosition() {
        /*DispatchQueue.global().async {
            
            let trains = AMTracker().getVehicles()
            
            if let specificTrain: AMVehicle = {
                for train in trains {
                    if train.trainNumber == self.train.trainNumber {
                        return train
                    }
                }
                return nil
            }() {
                DispatchQueue.main.sync {
                    self.train = self.train.placemarkWithNewLocation(specificTrain.location)
                    self.timeLabel.stringValue = "Updated at \(specificTrain.timeLastUpdated)"
                    
                    if self.station.coordinate.latitude == 52.31697130005335 && self.station.coordinate.longitude == 4.746418131532647 {
                        self.zoomMapToTrain()
                    } else {
                        self.zoomMapToTrainAndStation()
                    }
                }
            }
        }*/
    }
}

extension AMMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            //polylineRenderer.strokeColor = AMTracker.colors.beige
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
