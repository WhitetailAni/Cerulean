//
//  MTYMapView.swift
//  Cerulean
//
//  Created by WhitetailAni on 10/30/25.
//

import AppKit
import MapKit
import SwiftUI

class MTYMapView: MKMapView {
    var consists: [MTYardConsist]
    var timeLastUpdated: String
    var timeLabel: NSTextField!
    
    init(consists: [MTYardConsist], timeLastUpdated: String) {
        self.consists = consists
        self.timeLastUpdated = timeLastUpdated
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport, .park, .hospital, .library, .museum, .nationalPark, .restroom, .postOffice, .beach])
        
        self.register(MTYMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
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
        
        let refreshButton = NSButton(image: NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)!, target: self, action: #selector(refreshTrainsPosition))
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.mapType = .mutedStandard
        
        self.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            refreshButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            refreshButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
        ])
        
        zoomMapToTrains()
    }
    
    
    private func zoomMapToTrains() {
        self.removeAnnotations(self.annotations)
        var annotationArray: [MTYPointAnnotation] = []
        
        for consist in consists {
            let mark = MTYPlacemark(coordinate: consist.location)
            mark.carNumber = consist.headCarNumber
            let annotation = MTYPointAnnotation()
            annotation.coordinate = consist.location
            //annotation.title = "Data car \(consist.headCarNumber)"
            annotation.mark = mark
            
            annotationArray.append(annotation)
        }
        self.addAnnotations(annotationArray)
        
        var midpointLatitude = 0.0
        var midpointLongitude = 0.0
        
        var smallestLatitude = 180.0
        var biggestLatitude = 0.0
        var smallestLongitude = -180.0
        var biggestLongitude = 0.0
        
        for i in 0..<annotationArray.count {
            if annotationArray[i].coordinate.latitude < smallestLatitude {
                smallestLatitude = annotationArray[i].coordinate.latitude
            }
            if annotationArray[i].coordinate.latitude > biggestLatitude {
                biggestLatitude = annotationArray[i].coordinate.latitude
            }
            
            midpointLatitude += annotationArray[i].coordinate.latitude
        }
        for i in 0..<annotationArray.count {
            if annotationArray[i].coordinate.longitude > smallestLongitude {
                smallestLongitude = annotationArray[i].coordinate.longitude
            }
            if annotationArray[i].coordinate.longitude < biggestLongitude {
                biggestLongitude = annotationArray[i].coordinate.longitude
            }
            
            midpointLongitude += annotationArray[i].coordinate.longitude
        }
        
        midpointLatitude = midpointLatitude / Double(annotationArray.count)
        midpointLongitude = midpointLongitude / Double(annotationArray.count)
        
        print(midpointLatitude, midpointLongitude, smallestLatitude, biggestLatitude, smallestLongitude, biggestLongitude)
        
        let midpoint = CLLocationCoordinate2D(latitude: midpointLatitude, longitude: midpointLongitude)
        let latitudeDelta = abs(smallestLatitude - biggestLatitude) * 1.53
        let longitudeDelta = abs(smallestLongitude - biggestLongitude) * 1.53
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        self.setRegion(MKCoordinateRegion(center: midpoint, span: span), animated: true)
    }
    
    @objc func refreshTrainsPosition() {
        DispatchQueue.global().async {
            /*let raw = METXAPI().getActiveTrains()
            let allTrains = raw.0
            let trains = allTrains[self.train.service?.apiRepresentation() ?? ""] ?? []
            
            if let specificTrain = {
                for train in trains {
                    if train.trainNumber == self.train.trainNumber {
                        return train
                    }
                }
                return nil
            }() {
                DispatchQueue.main.sync {
                    self.train = self.train.placemarkWithNewLocation(specificTrain.location)
                    self.timeLabel.stringValue = "Updated at \(raw.1)"
                    
                    if self.station.coordinate.latitude == 52.31697130005335 && self.station.coordinate.longitude == 4.746418131532647 {
                        self.zoomMapToTrain()
                    } else {
                        self.zoomMapToTrainAndStation()
                    }
                }
            }*/
        }
    }
}
