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
    var windows: [NSWindow] = []
    var windowController: NSWindowController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        //statusItem.image = NSImage(systemSymbolName: "tram", accessibilityDescription: nil)
        //statusItem.image = .ctaSvg
        if let button = statusItem.button {
            print("gm")
            //button.image = .ctaSvg
            button.image = NSImage(systemSymbolName: "tram", accessibilityDescription: nil)
        }
        
        DispatchQueue.global().async {
            let instance = ChicagoTransitInterface()
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
            let item = NSMenuItem(title: line.textualRepresentation(), action: nil) //listing in main view
            let subMenu = NSMenu()
            subMenu.addItem(progressWheelItem())
            
            let instance = ChicagoTransitInterface()
            DispatchQueue.global().async {
                instance.getRunsForLine(line: line)
                instance.wait()
                let trains = InterfaceResultProcessing.cleanUpLineInfo(info: instance.returnedData)
                subMenu.removeItem(at: 0)
                
                DispatchQueue.main.sync {
                    if line == .purple && ChicagoTransitInterface.isPurpleExpressRunning() {
                        subMenu.addItem(NSMenuItem(title: "Express service active", action: nil))
                        subMenu.addItem(NSMenuItem.separator())
                    }
                    
                    
                    if ChicagoTransitInterface.hasServiceEnded(line: line) {
                        subMenu.addItem(NSMenuItem(title: "Line not in service", action: nil))
                    } else if trains.count == 0 {
                        subMenu.addItem(NSMenuItem(title: "No active trains", action: nil))
                    } else {
                        subMenu.addItem(NSMenuItem(title: "Last updated at \(Time.apiTimeToReadabletime(string: trains[0]["requestTime"] ?? ""))", action: nil))
                        subMenu.addItem(NSMenuItem.separator())
                        for train in trains {
                            let subItem = CRMenuItem(title: "\(train["run"] ?? "Unknown Run") to \(train["destinationStation"] ?? "Unknown Station")", action: #selector(self.openWindow(_:)))
                            let latitudeString = train["latitude"] ?? "0"
                            let longitudeString = train["longitude"] ?? "0"
                            subItem.trainCoordinate = CLLocationCoordinate2D(latitude: Double(latitudeString) ?? 0.0, longitude: Double(longitudeString) ?? 0.0)
                            subItem.trainLine = line
                            subItem.trainRun = train["run"] ?? "Unknown Run"
                            
                            let subSubMenu = NSMenu()
                            subSubMenu.addItem(self.progressWheelItem())
                            
                            let instance = ChicagoTransitInterface()
                            DispatchQueue.global().async {
                                let run = train["run"] ?? "000"
                                instance.getRunNumberInfo(run: run)
                                instance.wait()
                                let niceStats = InterfaceResultProcessing.cleanUpRunInfo(info: instance.returnedData)
                                subSubMenu.removeItem(at: 0)
                                
                                DispatchQueue.main.sync {
                                    let title = CRMenuItem(title: "\(line.textualRepresentation()) Line run \(run) to \(train["destinationStation"] ?? "Unknown destination")", action: #selector(self.openWindow(_:)))
                                    let latitudeString = train["latitude"] ?? "0"
                                    let longitudeString = train["longitude"] ?? "0"
                                    title.trainCoordinate = CLLocationCoordinate2D(latitude: Double(latitudeString) ?? 0.0, longitude: Double(longitudeString) ?? 0.0)
                                    title.trainLine = line
                                    title.trainRun = train["run"] ?? "Unknown Run"
                                    title.trainEndStop = train["destinationStation"] ?? "Bryn Mawr"
                                    title.trainEndStopID = train["destinationStationID"] ?? "30267"
                                    if niceStats.count == 0 {
                                        title.trainHasReachedEnd = true
                                    }
                                    
                                    subSubMenu.addItem(title)
                                    subSubMenu.addItem(NSMenuItem.separator())
                                    
                                    if niceStats.count == 0 {
                                        if train["destNm"] == "Error" {
                                            let errorString = train["lat"] ?? "An unknown error occurred"
                                            let errorItem = NSMenuItem(title: errorString, action: nil)
                                            subSubMenu.addItem(errorItem)
                                        } else {
                                            let arrivedAtDestinationItem = CRMenuItem(title: "Arrived at destination", action: #selector(self.openWindow(_:)))
                                            title.trainEndStop = train["destinationStation"] ?? "Bryn Mawr"
                                            arrivedAtDestinationItem.trainEndStopID = train["destinationStationID"] ?? "30267"
                                            arrivedAtDestinationItem.trainHasReachedEnd = true
                                            subSubMenu.addItem(arrivedAtDestinationItem)
                                        }
                                    } else {
                                        for station in niceStats {
                                            let subSubItem = CRMenuItem(title: "\(station["nextStation"] ?? "Unknown station") at \(Time.apiTimeToReadabletime(string: station["nextStationArrivalTime"] ?? ""))", action: #selector(self.openWindow(_:)))
                                            let latitudeString = train["latitude"] ?? "0"
                                            let longitudeString = train["longitude"] ?? "0"
                                            subSubItem.trainCoordinate = CLLocationCoordinate2D(latitude: Double(latitudeString) ?? 0.0, longitude: Double(longitudeString) ?? 0.0)
                                            subSubItem.trainLine = line
                                            subSubItem.trainRun = run
                                            subSubItem.trainDesiredStop = station["nextStation"]
                                            subSubItem.trainDesiredStopID = station["nextStopID"]
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
        if let screenSize = NSScreen.main?.frame.size {
            windows.append(NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.4, screenSize.height * 0.4), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false))
            let index = windows.count - 1
            let trainMark = CRPlacemark(coordinate: sender.trainCoordinate ?? CLLocationCoordinate2D(latitude: 41.88372, longitude: 87.63238))
            if let line = sender.trainLine, let run = sender.trainRun {
                let stationName = sender.trainDesiredStop ?? "Rochester"
                trainMark.line = line
                trainMark.trainRun = run
                trainMark.stationName = stationName
                
                let instance = ChicagoTransitInterface()
                if let id = sender.trainDesiredStopID {
                    windows[index].title = "Cerulean - \(sender.trainLine?.textualRepresentation() ?? "Unknown") Line run \(sender.trainRun ?? "000") to \(sender.trainDesiredStop ?? "Unknown")"
                    
                    DispatchQueue.global().async {
                        instance.getStationCoordinateForID(id: id)
                        instance.wait()
                        
                        if let latitudeString = instance.returnedData["latitude"] as? String?, let longitudeString = instance.returnedData["longitude"] as? String? {
                            let latitude = Double(latitudeString ?? "0") ?? 0
                            let longitude = Double(longitudeString ?? "0") ?? 0
                            
                            let stationMark = CRPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            stationMark.stationName = sender.trainDesiredStop
                            stationMark.line = line
                            
                            DispatchQueue.main.sync {
                                self.windows[index].contentView = CRMapView(train: trainMark, station: stationMark)
                                self.windows[index].center()
                                self.windows[index].makeKeyAndOrderFront(self.windows[index])
                                NSApp.activate(ignoringOtherApps: true)
                            }
                        }
                    }
                } else if sender.trainHasReachedEnd == true {
                    if let id = sender.trainEndStopID {
                        windows[index].title = "Cerulean - \(sender.trainLine?.textualRepresentation() ?? "Unknown") Line run \(sender.trainRun ?? "000") at \(sender.trainDesiredStop ?? "Unknown")"
                        
                        DispatchQueue.global().async {
                            instance.getStationCoordinateForID(id: id)
                            instance.wait()
                            
                            if let latitudeString = instance.returnedData["latitude"] as? String?, let longitudeString = instance.returnedData["longitude"] as? String? {
                                let latitude = Double(latitudeString ?? "0") ?? 0
                                let longitude = Double(longitudeString ?? "0") ?? 0
                                
                                let stationMark = CRPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                stationMark.line = line
                                stationMark.trainRun = run
                                stationMark.stationName = sender.trainEndStop
                                
                                DispatchQueue.main.sync {
                                    self.windows[index].contentView = CRMapView(train: stationMark)
                                    self.windows[index].center()
                                    self.windows[index].makeKeyAndOrderFront(self.windows[index])
                                    NSApp.activate(ignoringOtherApps: true)
                                }
                            }
                        }
                    }
                } else {
                    windows[index].title = "Cerulean - \(sender.trainLine?.textualRepresentation() ?? "Unknown") Line run \(sender.trainRun ?? "000")"
                    windows[index].contentView = CRMapView(train: trainMark)
                    windows[index].center()
                    windows[index].makeKeyAndOrderFront(windows[index])
                    
                    let delegate = MapWindowDelegate(closeWindow: {
                        self.windows.remove(at: index)
                    })
                    windows[index].delegate = delegate
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
    
    @objc func nop() { }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}

