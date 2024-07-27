//
//  AboutWindowDelegate.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit

class AboutWindowDelegate: NSObject, NSWindowDelegate {
    var window: NSWindow
    var closeWindow: (() -> Void)
    
    init(window: NSWindow, closeWindow: @escaping () -> Void) {
        self.window = window
        self.closeWindow = closeWindow
    }
    
    func windowDidResignMain(_ notification: Notification) {
        window.close()
    }
        
    func windowWillClose(_ notification: Notification) {
        closeWindow()
    }
}
