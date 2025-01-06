//
//  CRDPointAnnotation.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit
import MapKit

class CRDPointAnnotation: MKPointAnnotation {
    var mark: MKPlacemark?
    var markerTint: NSColor?
    var glyphTint: NSColor?
    var text: String?
    var image: NSImage?
}
