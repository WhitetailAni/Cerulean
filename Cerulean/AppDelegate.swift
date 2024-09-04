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
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var autoRefresh: AutomaticRefresh!
    
    var mapWindows: [NSWindow] = []
    var mapMutex = NSLock()
    
    var aboutWindows: [NSWindow] = []
    var aboutWindowDelegate: AboutWindowDelegate!
    var aboutMutex = NSLock()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            let image = NSImage(size: NSSize(width: 22, height: 22), flipped: false) { (rect) -> Bool in
                NSImage(named: "ctaTrain")!.tint(color: .white).draw(in: rect)
                return true
            }
            
            image.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeft
        }
        
        menu = NSMenu()
        refreshInfo()
        
        autoRefresh = AutomaticRefresh(interval: Bundle.main.infoDictionary?["CRRefreshInterval"] as? Double ?? 360.0) {
            self.refreshInfo()
        }
        autoRefresh.start()
        
        statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for window in mapWindows {
            window.close()
        }
        for aboutWindow in aboutWindows {
            aboutWindow.close()
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
    
    
    
    @MainActor @objc func refreshInfo() {
        menu.removeAllItems()
        let validLines = [CRLine.red, CRLine.blue, CRLine.brown, CRLine.green, CRLine.orange, CRLine.pink, CRLine.purple, CRLine.yellow]
        for line in validLines {
            let item = CRMenuItem(title: line.textualRepresentation(), action: #selector(openLink(_:)))
            item.linkToOpen = line.link()
            if line == .yellow {
                let yellowLineTitle = NSMutableAttributedString(string: line.textualRepresentation())
                
                let height = NSFont.menuFont(ofSize: 0).boundingRectForFont.height - 5
                let skokieSwiftBaseImage = NSImage(named: "skokieSwift")!
                let aspectRatio = skokieSwiftBaseImage.size.width / skokieSwiftBaseImage.size.height
                let newSize = NSSize(width: height * aspectRatio, height: height)
                    
                let skokieSwiftImage = NSImage(size: newSize)
                skokieSwiftImage.lockFocus()
                skokieSwiftBaseImage.draw(in: NSRect(origin: .zero, size: newSize))
                skokieSwiftImage.unlockFocus()
                
                let skokieSwift = NSTextAttachment()
                skokieSwift.image = skokieSwiftImage
                
                let skokieSwiftString = NSAttributedString(attachment: skokieSwift)
                yellowLineTitle.append(NSAttributedString(string: " "))
                yellowLineTitle.append(skokieSwiftString)
                item.attributedTitle = yellowLineTitle
            }
            item.trainLine = line
            
            let subMenu = NSMenu()
            subMenu.addItem(NSMenuItem.progressWheel())
            
            let instance = ChicagoTransitInterface()
            DispatchQueue.global().async {
                let trains = InterfaceResultProcessing.cleanUpLineInfo(info: instance.getRunsForLine(line: line))
                
                DispatchQueue.main.sync {
                    subMenu.removeItem(at: 0)
                    
                    if ChicagoTransitInterface.hasServiceEnded(line: line) {
                        subMenu.addItem(NSMenuItem(title: "Line not in service", action: nil))
                    } else if trains.count == 0 {
                        subMenu.addItem(NSMenuItem(title: "No active trains", action: nil))
                    } else {
                        let timeLastUpdated = CRTime.apiTimeToReadabletime(string: trains[0]["requestTime"] ?? "")
                        subMenu.addItem(NSMenuItem(title: "Last updated at \(timeLastUpdated)", action: nil))
                        subMenu.addItem(NSMenuItem.separator())
                        if line == .purple && ChicagoTransitInterface.isPurpleExpressRunning() {
                            let purpleExpressStatusItem = CRMenuItem(title: "Express service active", action: #selector(self.openLink(_:)))
                            purpleExpressStatusItem.linkToOpen = URL(string: "https://www.transitchicago.com/assets/1/6/rail-tt_purple.pdf")
                            subMenu.addItem(purpleExpressStatusItem)
                        }
                        for train in trains {
                            var line2 = line
                            if line == .green && train["destinationStation"] == "Cottage Grove" {
                                line2 = .greenAlternate
                            }
                            if line == .blue && train["destinationStation"] == "UIC-Halsted" {
                                line2 = .blueAlternate
                            }
                            var subItem: CRMenuItem!
                            if let latitudeString = train["latitude"], let longitudeString = train["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString), (latitude != 0 && longitude != 0) {
                                subItem = CRMenuItem(title: "\(train["run"] ?? "Unknown Run") to \(train["destinationStation"] ?? "Unknown Station")", action: #selector(self.openWindow(_:)))
                                subItem.trainCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                
                                subItem.trainLine = line2
                                subItem.trainRun = train["run"] ?? "Unknown Run"
                                
                                subItem.timeLastUpdated = timeLastUpdated
                            } else {
                                subItem = CRMenuItem(title: "\(train["run"] ?? "Unknown Run") to \(train["destinationStation"] ?? "Unknown Station")", action: nil)
                            }
                            
                            let subSubMenu = NSMenu()
                            subSubMenu.addItem(NSMenuItem.progressWheel())
                            subItem.submenu = subSubMenu
                            subMenu.addItem(subItem)
                            
                            #warning("Station prediction for train starts here")
                            let instance = ChicagoTransitInterface()
                            DispatchQueue.global().async {
                                let run = train["run"] ?? "000"
                                let niceStats = InterfaceResultProcessing.cleanUpRunInfo(info: instance.getRunNumberInfo(run: run))
                                
                                DispatchQueue.main.sync {
                                    subSubMenu.removeItem(at: 0)
                                    
                                    var title: CRMenuItem!
                                    if let latitudeString = train["latitude"], let longitudeString = train["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
                                        title = CRMenuItem(title: "\(line.textualRepresentation()) Line run \(run) to \(train["destinationStation"] ?? "Unknown destination")", action: #selector(self.openWindow(_:)))
                                        title.trainCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                        title.trainLine = line2
                                        
                                        title.trainRun = train["run"] ?? "Unknown Run"
                                        title.trainDesiredStop = train["destinationStation"] ?? "Bryn Mawr"
                                        title.trainEndStop = train["destinationStation"] ?? "Bryn Mawr"
                                        title.trainEndStopID = train["destinationStationID"] ?? "30267"
                                        title.timeLastUpdated = timeLastUpdated
                                        if niceStats.count == 0 {
                                            title.trainHasReachedEnd = true
                                        }
                                    } else {
                                        title = CRMenuItem(title: "\(line.textualRepresentation()) Line run \(run) to \(train["destinationStation"] ?? "Unknown destination")", action: nil)
                                    }
                                    
                                    subSubMenu.addItem(title)
                                    subSubMenu.addItem(NSMenuItem.separator())
                                    
                                    if niceStats.count == 0 {
                                        if train["destNm"] == "Error" {
                                            let errorString = train["lat"] ?? "An unknown error occurred"
                                            let errorItem = NSMenuItem(title: errorString, action: nil)
                                            subSubMenu.addItem(errorItem)
                                        } else {
                                            subSubMenu.addItem(NSMenuItem(title: "No predictions available", action: nil))
                                        }
                                    } else {
                                        #warning("Adding items to subSubMenu is the station predictions")
                                        for station in niceStats {
                                            var subSubItem: CRMenuItem!
                                            if let latitudeString = train["latitude"], let longitudeString = train["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString), (latitude != 0 && longitude != 0) {
                                                subSubItem = CRMenuItem(title: "\(station["nextStation"] ?? "Unknown station") at \(CRTime.apiTimeToReadabletime(string: station["nextStationArrivalTime"] ?? ""))", action: #selector(self.openWindow(_:)))
                                                subSubItem.trainCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                                subSubItem.trainLine = line2
                                                subSubItem.trainRun = run
                                                subSubItem.trainDesiredStop = station["nextStation"]
                                                subSubItem.trainDesiredStopID = station["nextStopID"]
                                                subSubItem.timeLastUpdated = timeLastUpdated
                                            } else {
                                                subSubItem = CRMenuItem(title: "\(station["nextStation"] ?? "Unknown station") at \(CRTime.apiTimeToReadabletime(string: station["nextStationArrivalTime"] ?? ""))", action: nil)
                                            }
                                            
                                            subSubMenu.addItem(subSubItem)
                                            
                                            let subSubSubMenu = NSMenu()
                                            let alertLink = URL(string: "https://www.transitchicago.com/alerts/")
                                            let delayItem = CRMenuItem(title: "Delayed: \(station["isDelayed"] ?? "Unknown")", action: #selector(self.openLink(_:)))
                                            delayItem.linkToOpen = alertLink
                                            
                                            let faultItem = CRMenuItem(title: "Fault detected: \(station["isBreakingDown"] ?? "Unknown")", action: #selector(self.openLink(_:)))
                                            faultItem.linkToOpen = alertLink
                                            
                                            let approachingItem = CRMenuItem(title: "Scheduled: \(station["isScheduled"] ?? "Unknown")", action: #selector(self.openLink(_:)))
                                            approachingItem.linkToOpen = alertLink
                                            
                                            subSubSubMenu.addItem(delayItem)
                                            subSubSubMenu.addItem(faultItem)
                                            subSubSubMenu.addItem(approachingItem)
                                            
                                            subSubItem.submenu = subSubSubMenu
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            item.submenu = subMenu
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(title: "About", action: #selector(openAboutWindow), keyEquivalent: "a")
        aboutItem.keyEquivalentModifierMask = [.command]
        menu.addItem(aboutItem)
        
        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshInfo), keyEquivalent: "r")
        refreshItem.keyEquivalentModifierMask = [.command]
        menu.addItem(refreshItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        menu.addItem(quitItem)
    }
    
    @objc func openWindow(_ sender: CRMenuItem) {
        mapMutex.lock()
        if let screenSize = NSScreen.main?.frame.size {
            let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            let index = mapWindows.count
            mapWindows.append(window)
            
            let trainMark = CRPlacemark(coordinate: sender.trainCoordinate ?? CLLocationCoordinate2D(latitude: 41.88372, longitude: 87.63238))
            
            if let line = sender.trainLine, let run = sender.trainRun, let timeLastUpdated = sender.timeLastUpdated {
                let stationName = sender.trainDesiredStop ?? "Rochester"
                trainMark.line = line
                trainMark.trainRun = run
                trainMark.stationName = stationName
                
                let instance = ChicagoTransitInterface()
                if let id = sender.trainDesiredStopID {
                    mapWindows[index].title = "Cerulean - \(sender.trainLine?.textualRepresentation() ?? "Unknown") Line run \(sender.trainRun ?? "000") to \(sender.trainDesiredStop ?? "Unknown")"
                    
                    DispatchQueue.global().async {
                        let returnedData = instance.getStopCoordinateForID(id: id)
                        
                        if let latitudeString = returnedData["latitude"] as? String, let longitudeString = returnedData["longitude"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
                            
                            let stationMark = CRPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            stationMark.stationName = sender.trainDesiredStop
                            stationMark.line = line
                            
                            DispatchQueue.main.sync {
                                self.mapWindows[index].contentView = CRMapView(train: trainMark, station: stationMark, timeLastUpdated: timeLastUpdated)
                                self.mapWindows[index].center()
                                self.mapWindows[index].setIsVisible(true)
                                self.mapWindows[index].orderFrontRegardless()
                                self.mapWindows[index].makeKey()
                                NSApp.activate(ignoringOtherApps: true)
                            }
                        }
                    }
                } else if sender.trainHasReachedEnd == true {
                    if let id = sender.trainEndStopID {
                        mapWindows[index].title = "Cerulean - \(sender.trainLine?.textualRepresentation() ?? "Unknown") Line run \(sender.trainRun ?? "000") at \(sender.trainDesiredStop ?? "Unknown")"
                        
                        DispatchQueue.global().async { [self] in
                            let returnedData = instance.getStopCoordinateForID(id: id)
                            
                            if let latitudeString = returnedData["latitude"] as? String, let longitudeString = returnedData["longitude"] as? String, let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
                                
                                let stationMark = CRPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                stationMark.line = line
                                stationMark.trainRun = run
                                stationMark.stationName = sender.trainEndStop
                                
                                DispatchQueue.main.sync {
                                    self.mapWindows[index].contentView = CRMapView(train: stationMark, timeLastUpdated: timeLastUpdated)
                                    self.mapWindows[index].center()
                                    self.mapWindows[index].setIsVisible(true)
                                    self.mapWindows[index].orderFrontRegardless()
                                    self.mapWindows[index].makeKey()
                                    NSApp.activate(ignoringOtherApps: true)
                                }
                            }
                        }
                    }
                } else {
                    mapWindows[index].title = "Cerulean - \(sender.trainLine?.textualRepresentation() ?? "Unknown") Line run \(sender.trainRun ?? "000")"
                    mapWindows[index].contentView = CRMapView(train: trainMark, timeLastUpdated: timeLastUpdated)
                    mapWindows[index].center()
                    mapWindows[index].setIsVisible(true)
                    mapWindows[index].orderFrontRegardless()
                    mapWindows[index].makeKey()
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
        mapMutex.unlock()
    }
    
    @objc func openAboutWindow() {
        aboutMutex.lock()
        if let screenSize = NSScreen.main?.frame.size {
            let defaultRect = NSMakeRect(0, 0, screenSize.width * 0.27, screenSize.height * 0.27)
            aboutWindows.append(NSWindow(contentRect: defaultRect, styleMask: [.titled, .closable], backing: .buffered, defer: false))
            let index = aboutWindows.count - 1
            
            aboutWindows[index].contentView = NSHostingView(rootView: AboutView())
            aboutWindows[index].title = "Cerulean \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "772")) - About"
            aboutWindows[index].center()
            aboutWindows[index].setIsVisible(true)
            aboutWindows[index].orderFrontRegardless()
            aboutWindows[index].makeKey()
            NSApp.activate(ignoringOtherApps: true)
            
            aboutWindowDelegate = AboutWindowDelegate(window: aboutWindows[index])
            aboutWindows[index].delegate = aboutWindowDelegate
        }
        aboutMutex.unlock()
    }
    
    @objc func openLink(_ sender: CRMenuItem) {
        if let link = sender.linkToOpen {
            NSWorkspace.shared.open(link)
        }
    }
    
    @objc func nop() { }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}
