//
//  CRWindowController.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/24/24.
//

import AppKit

class MapWindowDelegate: NSObject, NSWindowDelegate {
    var closeWindow: (() -> Void)
    
    init(closeWindow: @escaping () -> Void) {
        self.closeWindow = closeWindow
    }
        
    func windowWillClose(_ notification: Notification) {
        closeWindow()
    }
}
