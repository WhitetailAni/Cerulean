//
//  AppDelegate.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import Cocoa
import AppKit
import Foundation
import CoreLocation
import MapKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var progressIndicator: NSProgressIndicator!
    var menu: NSMenu!
    var window: NSWindow!
    var windowController: NSWindowController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "tram", accessibilityDescription: "Train")
        }
        
        menu = NSMenu()
        refreshInfo()
        
        statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func progressWheelItem() -> NSMenuItem {
        progressIndicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 16, height: 16))
        progressIndicator.style = .spinning
        progressIndicator.isIndeterminate = true
        progressIndicator.controlSize = .small
        progressIndicator.isDisplayedWhenStopped = false
        
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let progressMenuItem = NSMenuItem()
        progressMenuItem.view = progressIndicator
        
        progressIndicator.startAnimation(nil)
        return progressMenuItem
    }
    
    @objc func refreshInfo() {
        menu.removeAllItems()
        let validLines = [Line.red, Line.blue, Line.brown, Line.green, Line.orange, Line.pink, Line.purple, Line.yellow]
        for line in validLines {
            let item = NSMenuItem(title: line.textualRepresentation(), action: nil, keyEquivalent: "") //listing in main view
            let subMenu = NSMenu()
            subMenu.addItem(progressWheelItem())
            
            let instance = ChicagoTransitInterface()
            DispatchQueue.global().async {
                instance.getRunsForLine(line: line)
                while instance.requestInProgress { }
                let trains = InterfaceResultProcessing.cleanUpLineInfo(info: instance.returnedData)
                subMenu.removeItem(at: 0)
                
                DispatchQueue.main.sync {
                    if line == .purple && ChicagoTransitInterface.isPurpleExpressRunning() {
                        subMenu.addItem(NSMenuItem(title: "Express service active", action: nil, keyEquivalent: ""))
                        subMenu.addItem(NSMenuItem.separator())
                    }
                    
                    if trains.count == 0 {
                        subMenu.addItem(NSMenuItem(title: "No active trains", action: nil, keyEquivalent: ""))
                    } else {
                        subMenu.addItem(NSMenuItem(title: "Last updated at \(Time.apiTimeToReadabletime(string: trains[0]["requestTime"] ?? ""))", action: nil, keyEquivalent: ""))
                        subMenu.addItem(NSMenuItem.separator())
                        for train in trains {
                            let subItem = NSMenuItem(title: "\(train["run"] ?? "Unknown Run") to \(train["destinationStation"] ?? "Unknown Station")", action: nil, keyEquivalent: "")
                            let subSubMenu = NSMenu()
                            subSubMenu.addItem(self.progressWheelItem())
                            
                            let instance = ChicagoTransitInterface()
                            DispatchQueue.global().async {
                                let run = train["run"] ?? "000"
                                instance.getRunNumberInfo(run: run)
                                while instance.requestInProgress { }
                                let niceStats = InterfaceResultProcessing.cleanUpRunInfo(info: instance.returnedData)
                                subSubMenu.removeItem(at: 0)
                                
                                
                                let title = NSMenuItem(title: "\(line.textualRepresentation()) Line run \(run) to \(train["destinationStation"] ?? "Unknown destination")", action: #selector(self.nop), keyEquivalent: "")
                                subSubMenu.addItem(title)
                                subSubMenu.addItem(NSMenuItem.separator())
                                
                                if niceStats.count == 0 {
                                    subSubMenu.addItem(NSMenuItem(title: "Arrived at destination", action: #selector(self.nop), keyEquivalent: ""))
                                } else {
                                    for station in niceStats {
                                        let subSubItem = CRMenuItem(title: "\(station["nextStation"] ?? "Unknown station") at \(Time.apiTimeToReadabletime(string: station["nextStationArrivalTime"] ?? ""))", action: #selector(self.openWindow(_:)), keyEquivalent: "")
                                        let latitudeString = station["latitude"] ?? "0"
                                        let longitudeString = station["longitude"] ?? "0"
                                        subSubItem.trainCoordinate = CLLocationCoordinate2D(latitude: Double(latitudeString) ?? 0.0, longitude: Double(longitudeString) ?? 0.0)
                                        subSubItem.trainLine = line
                                        subSubItem.trainRun = run
                                        subSubItem.trainDesiredStop = station["nextStation"]
                                        #warning("Figure out if the station (directional) or stop (overall station) ID is needed here")
                                        subSubItem.trainDesiredStopID = station["nextStationID"]
                                        subSubMenu.addItem(subSubItem)
                                        
                                        let subSubSubMenu = NSMenu()
                                        let delayItem = NSMenuItem(title: "Delayed: \(station["isDelayed"] ?? "Unknown")", action: #selector(self.nop), keyEquivalent: "")
                                        let faultItem = NSMenuItem(title: "Fault detected: \(station["isBreakingDown"] ?? "Unknown")", action: #selector(self.nop), keyEquivalent: "")
                                        let approachingItem = NSMenuItem(title: "Scheduled: \(station["isScheduled"] ?? "Unknown")", action: #selector(self.nop), keyEquivalent: "")
                                        subSubSubMenu.addItem(delayItem)
                                        subSubSubMenu.addItem(faultItem)
                                        subSubSubMenu.addItem(approachingItem)
                                        
                                        subSubItem.submenu = subSubSubMenu
                                    }
                                }
                            }
                            
                            subItem.submenu = subSubMenu
                            subMenu.addItem(subItem)
                        }
                    }
                }
            }
            
            item.submenu = subMenu
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())
        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshInfo), keyEquivalent: "r")
        refreshItem.keyEquivalentModifierMask = [.command]
        menu.addItem(refreshItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        menu.addItem(quitItem)
    }
    
    @objc func openWindow(_ sender: CRMenuItem) {
        print("gm")

        let window = NSWindow(contentRect: NSMakeRect(0, 0, 400, 300), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Cerulean - \(sender.trainLine?.textualRepresentation() ?? "Unknown") Line run \(sender.trainRun ?? "000") to \(sender.trainDesiredStop ?? "Unknown")"
        window.center()
        window.makeKeyAndOrderFront(window)
        NSApp.activate(ignoringOtherApps: true)
        let trainMark = CRPlacemark(coordinate: sender.trainCoordinate ?? CLLocationCoordinate2D(latitude: 41.88372, longitude: 87.63238))
        let stationMark = CRPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37, longitude: 42))
        window.contentView = CRMapView(train: trainMark, station: stationMark)
    }
    
    @objc func nop() { }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}

