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
    var ctaMenu: NSMenu!
    var metraMenu: NSMenu!
    var autoRefresh: AutomaticRefresh!
    
    var mapWindows: [NSWindow] = []
    var mapMutex = NSLock()
    
    var aboutWindows: [NSWindow] = []
    var aboutWindowDelegate: AboutWindowDelegate!
    var aboutMutex = NSLock()
    
    var actuallyBrown: [CRMenuItem] = []
    var brownReady = false
    var orangeReady = false
    
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
        
        let ctaItem = CRMenuItem(title: "CTA", action: #selector(openLink(_:)))
        ctaItem.linkToOpen = URL(string: "https://www.transitchicago.com/traintracker/")!
        let ctaTitle = prependImageToString(imageName: "cta", title: "CTA")
        ctaItem.attributedTitle = ctaTitle
        ctaMenu = NSMenu()
        ctaItem.submenu = ctaMenu
        
        menu.addItem(ctaItem)
        
        let metraItem = CRMenuItem(title: "", action: #selector(openLink(_:)))
        metraItem.linkToOpen = URL(string: "https://metra.com/metratracker")!
        let metraTitle = prependImageToString(imageName: "metra", title: "Metra")
        metraItem.attributedTitle = metraTitle
        metraMenu = NSMenu()
        metraItem.submenu = metraMenu
        
        menu.addItem(metraItem)
        
        refreshInfo()
        
        menu.addItem(NSMenuItem.separator())
        
        if Bundle.main.infoDictionary?["CRDebug"] as? Bool ?? false {
            let debugItem = NSMenuItem(title: "Debug", action: #selector(openAboutWindow), keyEquivalent: "d")
            debugItem.keyEquivalentModifierMask = [.command]
            menu.addItem(debugItem)
            
            let debugMenu = NSMenu()
            
            let trackerMapItem = CRMenuItem(title: "Overview", action: #selector(openDebugMapWindow(_:)))
            debugMenu.addItem(trackerMapItem)
            
            debugItem.submenu = debugMenu
            
            menu.addItem(NSMenuItem.separator())
        }
        
        let aboutItem = NSMenuItem(title: "About", action: #selector(openAboutWindow), keyEquivalent: "a")
        aboutItem.keyEquivalentModifierMask = [.command]
        menu.addItem(aboutItem)
        
        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshInfo), keyEquivalent: "r")
        refreshItem.keyEquivalentModifierMask = [.command]
        menu.addItem(refreshItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        menu.addItem(quitItem)
        
        
        autoRefresh = AutomaticRefresh(interval: Bundle.main.infoDictionary?["CRRefreshInterval"] as? Double ?? 360.0) {
            self.refreshInfo()
        }
        autoRefresh.start()
        
        statusItem.menu = menu
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
    
    func prependImageToString(imageName: String, title: String) -> NSMutableAttributedString {
        let height = NSFont.menuFont(ofSize: 0).boundingRectForFont.height - 5
        let baseImage = NSImage(named: imageName)!
        
        let aspectRatio = baseImage.size.width / baseImage.size.height
        let newSize = NSSize(width: height * aspectRatio, height: height)
            
        let image = NSImage(size: newSize)
        image.lockFocus()
        baseImage.draw(in: NSRect(origin: .zero, size: newSize))
        image.unlockFocus()
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        
        let resultingString = NSAttributedString(attachment: imageAttachment)
        
        let attributedTitle = NSMutableAttributedString(string: "")
        attributedTitle.append(resultingString)
        attributedTitle.append(NSAttributedString(string: " "))
        attributedTitle.append(NSAttributedString(string: title))
        
        return attributedTitle
    }
    
    @MainActor @objc func refreshInfo() {
        refreshCTAInfo()
        refreshMetraInfo()
    }
    
    @MainActor @objc func refreshCTAInfo() {
        ctaMenu.removeAllItems()
        actuallyBrown = []
        for line in [CRLine.red, CRLine.blue, CRLine.green, CRLine.orange, CRLine.pink, CRLine.purple, CRLine.yellow] {
            let item = populateCTAMenuItem(line: line)
            ctaMenu.addItem(item)
        }
        
        let item = populateCTAMenuItem(line: .brown)
        ctaMenu.insertItem(item, at: 2)
        
        ctaMenu.addItem(NSMenuItem.separator())
        
        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshCTAInfo), keyEquivalent: "r")
        refreshItem.keyEquivalentModifierMask = [.command]
        ctaMenu.addItem(refreshItem)
    }
    
    @MainActor private func populateCTAMenuItem(line: CRLine) -> CRMenuItem {
        let lineItem = CRMenuItem(title: line.textualRepresentation(), action: #selector(openLink(_:)))
        lineItem.linkToOpen = line.link()
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
            lineItem.attributedTitle = yellowLineTitle
        }
        lineItem.trainLine = line
        
        let trainMenu = NSMenu()
        trainMenu.addItem(NSMenuItem.progressWheel())
        
        let instance = ChicagoTransitInterface()
        DispatchQueue.global().async {
            let trains = InterfaceResultProcessing.cleanUpLineInfo(info: instance.getRunsForLine(line: line))
            
            DispatchQueue.main.sync {
                trainMenu.removeItem(at: 0)
                
                if ChicagoTransitInterface.hasServiceEnded(line: line) {
                    trainMenu.addItem(NSMenuItem(title: "Line not in service", action: nil))
                } else if trains.count == 0 {
                    trainMenu.addItem(NSMenuItem(title: "No active trains", action: nil))
                } else {
                    let timeLastUpdated = CRTime.ctaAPITimeToReadableTime(string: trains[0]["requestTime"] ?? "")
                    trainMenu.addItem(NSMenuItem(title: "Last updated at \(timeLastUpdated)", action: nil))
                    trainMenu.addItem(NSMenuItem.separator())
                    if line == .purple && ChicagoTransitInterface.isPurpleExpressRunning() {
                        let purpleExpressStatusItem = CRMenuItem(title: "Express service active", action: #selector(self.openLink(_:)))
                        purpleExpressStatusItem.linkToOpen = URL(string: "https://www.transitchicago.com/assets/1/6/rail-tt_purple.pdf")
                        trainMenu.addItem(purpleExpressStatusItem)
                    }
                    for train in trains {
                        let destination = train["destinationStation"] ?? "Unknown Station"
                        var line2 = line
                        if line == .green && destination == "Cottage Grove" {
                            line2 = .greenAlternate
                        }
                        if line == .blue && destination == "UIC-Halsted" {
                            line2 = .blueAlternate
                        }
                        if line == .orange && destination == "Kimball" {
                            line2 = .brown
                        }
                        let run = train["run"] ?? "Unknown Run"
                        
                        var trainItem: CRMenuItem!
                        if let latitudeString = train["latitude"], let longitudeString = train["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString), (latitude != 0 && longitude != 0) {
                            
                            trainItem = CRMenuItem(title: "\(run) to \(destination)", action: #selector(self.openCTAMapWindow(_:)))
                            trainItem.trainCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            
                            if destination == "Downtown, Kimball" || ((Int(run) ?? 000) / 100) % 10 == 7 {
                                trainItem.isBrownge = true
                            }
                            
                            trainItem.trainLine = line2
                            trainItem.trainRun = train["run"] ?? "Unknown Run"
                            
                            trainItem.timeLastUpdated = timeLastUpdated
                        } else {
                            trainItem = CRMenuItem(title: "\(run) to \(destination)", action: nil)
                        }
                        
                        let stationMenu = NSMenu()
                        stationMenu.addItem(NSMenuItem.progressWheel())
                        trainItem.submenu = stationMenu
                        
                        trainMenu.addItem(trainItem)
                        
                        #warning("Station prediction for train starts here")
                        let instance = ChicagoTransitInterface()
                        DispatchQueue.global().async {
                            let run = train["run"] ?? "000"
                            let niceStats = InterfaceResultProcessing.cleanUpRunInfo(info: instance.getRunNumberInfo(run: run))
                            
                            DispatchQueue.main.sync {
                                stationMenu.removeItem(at: 0)
                                //let destination = train["destinationStation"] ?? "Unknown Station"
                                
                                var title: CRMenuItem!
                                if let latitudeString = train["latitude"], let longitudeString = train["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
                                    
                                    title = CRMenuItem(title: "\(line2.textualRepresentation()) Line run \(run) to \(destination)", action: #selector(self.openCTAMapWindow(_:)))
                                    title.trainCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    title.trainLine = line2
                                    
                                    if destination == "Downtown, Kimball" || ((Int(run) ?? 000) / 100) % 10 == 7 {
                                        title.isBrownge = true
                                    }
                                    
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
                                    if destination == "Downtown, Kimball" || ((Int(run) ?? 000) / 100) % 10 == 7  {
                                        title.isBrownge = true
                                    }
                                }
                                
                                stationMenu.addItem(title)
                                stationMenu.addItem(NSMenuItem.separator())
                                
                                if niceStats.count == 0 {
                                    if train["destNm"] == "Error" {
                                        let errorString = train["lat"] ?? "An unknown error occurred"
                                        let errorItem = NSMenuItem(title: errorString, action: nil)
                                        stationMenu.addItem(errorItem)
                                    } else {
                                        stationMenu.addItem(NSMenuItem(title: "No predictions available", action: nil))
                                    }
                                } else {
                                    for station in niceStats {
                                        var stationItem: CRMenuItem!
                                        if let latitudeString = train["latitude"], let longitudeString = train["longitude"], let latitude = Double(latitudeString), let longitude = Double(longitudeString), (latitude != 0 && longitude != 0) {
                                            stationItem = CRMenuItem(title: "\(station["nextStation"] ?? "Unknown station") at \(CRTime.ctaAPITimeToReadableTime(string: station["nextStationArrivalTime"] ?? ""))", action: #selector(self.openCTAMapWindow(_:)))
                                            stationItem.trainCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                            stationItem.trainLine = line2
                                            stationItem.trainRun = run
                                            stationItem.trainDesiredStop = station["nextStation"]
                                            stationItem.trainDesiredStopID = station["nextStopID"]
                                            stationItem.timeLastUpdated = timeLastUpdated
                                            
                                            if destination == "Downtown, Kimball" || ((Int(run) ?? 000) / 100) % 10 == 7  {
                                                stationItem.isBrownge = true
                                            }
                                            
                                        } else {
                                            stationItem = CRMenuItem(title: "\(station["nextStation"] ?? "Unknown station") at \(CRTime.ctaAPITimeToReadableTime(string: station["nextStationArrivalTime"] ?? ""))", action: nil)
                                        }
                                        
                                        stationMenu.addItem(stationItem)
                                        
                                        let moreInfoMenu = NSMenu()
                                        let alertLink = URL(string: "https://www.transitchicago.com/alerts/")
                                        let delayItem = CRMenuItem(title: "Delayed: \(station["isDelayed"] ?? "Unknown")", action: #selector(self.openLink(_:)))
                                        delayItem.linkToOpen = alertLink
                                        
                                        let faultItem = CRMenuItem(title: "Fault detected: \(station["isBreakingDown"] ?? "Unknown")", action: #selector(self.openLink(_:)))
                                        faultItem.linkToOpen = alertLink
                                        
                                        let approachingItem = CRMenuItem(title: "Scheduled: \(station["isScheduled"] ?? "Unknown")", action: #selector(self.openLink(_:)))
                                        approachingItem.linkToOpen = alertLink
                                        
                                        moreInfoMenu.addItem(delayItem)
                                        moreInfoMenu.addItem(faultItem)
                                        moreInfoMenu.addItem(approachingItem)
                                        
                                        stationItem.submenu = moreInfoMenu
                                    }
                                }
                                self.orangeReady = true
                            }
                        }
                    }
                    
                    //brownge trains do not obey the rules, so i have to make them obey the rules
                    DispatchQueue.global().async {
                        if line == .orange {
                            while !self.orangeReady { usleep(10) }
                            DispatchQueue.main.sync {
                                for i in 0..<trainMenu.items.count {
                                    let item = trainMenu.items[i] as? CRMenuItem ?? CRMenuItem()
                                    if item.title.suffix(7) == "Kimball" {
                                        self.actuallyBrown.append(item)
                                        self.brownReady = true
                                        trainMenu.removeItem(at: i)
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.global().async {
                        if line == .brown {
                            while !self.brownReady { usleep(10) }
                            DispatchQueue.main.sync {
                                for item in self.actuallyBrown {
                                    trainMenu.addItem(item)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        lineItem.submenu = trainMenu
        
        return lineItem
    }
    
    @MainActor @objc func refreshMetraInfo() {
        metraMenu.removeAllItems()
        
        DispatchQueue.global().async {
            let rawTrainData = METXAPI().getActiveTrains()
            let allConsists = rawTrainData.0
            let timeLastUpdated = rawTrainData.1
            
            let allPredictionData = METXAPI().getStopPredictions()
            
            DispatchQueue.main.sync {
                let services = MTService.allServices
                for service in services {
                    let item = CRMenuItem(title: service.textualRepresentation(), action: #selector(self.openLink(_:)))
                    
                    let apiRepresentation = service.apiRepresentation()
                    
                    let consists = allConsists[apiRepresentation] ?? []
                    let predictionsForService = allPredictionData[apiRepresentation] ?? []
                    
                    let trainMenu = NSMenu()
                    
                    if service == .bnsf {
                         let bnsfTitle = NSMutableAttributedString(string: "")
                         
                         let height = NSFont.menuFont(ofSize: 0).boundingRectForFont.height - 5
                         let bnsfBaseImage = NSImage(named: "bnsf")!
                         let aspectRatio = bnsfBaseImage.size.width / bnsfBaseImage.size.height
                         let newSize = NSSize(width: height * aspectRatio, height: height)
                         
                         let bnsfImage = NSImage(size: newSize)
                         bnsfImage.lockFocus()
                         bnsfBaseImage.draw(in: NSRect(origin: .zero, size: newSize))
                         bnsfImage.unlockFocus()
                         
                         let bnsf = NSTextAttachment()
                         bnsf.image = bnsfImage
                         
                         let bnsfString = NSAttributedString(attachment: bnsf)
                         bnsfTitle.append(bnsfString)
                         item.attributedTitle = bnsfTitle
                    }
                    item.linkToOpen = service.link()
                    
                    self.metraMenu.addItem(item)
                    
                    if service.outOfService() {
                        trainMenu.addItem(NSMenuItem(title: "Line not in service", action: nil))
                    } else if consists.count == 0 {
                        trainMenu.addItem(NSMenuItem(title: "No active trains", action: nil))
                    } else {
                        trainMenu.addItem(NSMenuItem(title: "Last updated at \(timeLastUpdated)", action: nil))
                        trainMenu.addItem(NSMenuItem.separator())
                        
                        for consist in consists {
                            let endDestination = consist.service.getDestination(trainString: consist.trainNumber)
                            let trainItem = MTMenuItem(title: "\(consist.trainNumber) to \(endDestination)", action: #selector(self.openMetraMapWindow(_:)))
                            trainItem.trainCoordinate = consist.location
                            trainItem.trainNumber = consist.trainNumber
                            trainItem.service = service
                            
                            let stopMenu = NSMenu()
                            
                            let titleItem = MTMenuItem(title: "\(service.textualRepresentation()) train \(consist.trainNumber) to \(endDestination)", action: #selector(self.openMetraMapWindow(_:)))
                            titleItem.trainCoordinate = consist.location
                            titleItem.trainNumber = consist.trainNumber
                            titleItem.service = service
                            
                            stopMenu.addItem(titleItem)
                            stopMenu.addItem(NSMenuItem.separator())
                            
                            if let trainSpecificPredictions: MTPrediction = {
                                for prediction in predictionsForService {
                                    if consist.trainNumber == prediction.trainNumber {
                                        return prediction
                                    }
                                }
                                return nil
                            }() {
                                let stops = trainSpecificPredictions.stops
                                
                                if stops.count > 0 {
                                    for stop in stops {
                                        let purifiedName = MTStop.purifyApiName(name: stop.apiName)
                                        if stop.arrivalTime == stop.departureTime {
                                            let stopItem = MTMenuItem(title: "\(purifiedName) at \(CRTime.dateToReadableTime(date: stop.arrivalTime))", action: #selector(self.openMetraMapWindow(_:)))
                                            stopItem.trainNumber = consist.trainNumber
                                            stopItem.service = service
                                            stopItem.stationID = stop.apiName
                                            stopItem.stationName = purifiedName
                                            stopItem.trainCoordinate = consist.location
                                            
                                            stopMenu.addItem(stopItem)
                                        } else {
                                            let arriveItem = MTMenuItem(title: "Arrives \(purifiedName) at \(CRTime.dateToReadableTime(date: stop.arrivalTime))", action: #selector(self.openMetraMapWindow(_:)))
                                            arriveItem.trainNumber = consist.trainNumber
                                            arriveItem.service = service
                                            arriveItem.stationID = stop.apiName
                                            arriveItem.stationName = purifiedName
                                            arriveItem.trainCoordinate = consist.location
                                            
                                            let departItem = MTMenuItem(title: "Departs \(purifiedName) at \(CRTime.dateToReadableTime(date: stop.departureTime))", action: #selector(self.openMetraMapWindow(_:)))
                                            departItem.trainNumber = consist.trainNumber
                                            departItem.service = service
                                            departItem.stationID = stop.apiName
                                            departItem.stationName = purifiedName
                                            departItem.trainCoordinate = consist.location
                                            
                                            stopMenu.addItem(arriveItem)
                                            stopMenu.addItem(departItem)
                                        }
                                    }
                                } else {
                                    let stopItem = MTMenuItem(title: "Arrived at terminal", action: nil)
                                    
                                    stopMenu.addItem(stopItem)
                                }
                            }
                            
                            trainItem.submenu = stopMenu
                            
                            trainMenu.addItem(trainItem)
                        }
                    }
                    
                    item.submenu = trainMenu
                }
                self.metraMenu.addItem(NSMenuItem.separator())
                self.metraMenu.addItem(NSMenuItem(title: "Refresh", action: #selector(self.refreshMetraInfo), keyEquivalent: "r"))
            }
        }
    }
    
    @objc func openCTAMapWindow(_ sender: CRMenuItem) {
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
                
                trainMark.isBrownge = sender.isBrownge
                
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
                    mapWindows[index].title = "Cerulean - CTA \(sender.trainLine?.textualRepresentation() ?? "Unknown") Line run \(sender.trainRun ?? "000")"
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
    
    @objc func openMetraMapWindow(_ sender: MTMenuItem) {
        mapMutex.lock()
        if let screenSize = NSScreen.main?.frame.size {
            let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            let index = mapWindows.count
            mapWindows.append(window)
            
            let placemark = MTPlacemark(coordinate: sender.trainCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
            
            if let trainNumber = sender.trainNumber, let service = sender.service, let stationName = sender.stationName, let stationID = sender.stationID {
                placemark.service = service
                placemark.trainNumber = trainNumber
                
                let station = METXAPI.stations.getStop(service: service, apiName: stationID)
                
                let stopMark = MTPlacemark(coordinate: station.location)
                stopMark.stationName = stationName
                stopMark.service = service
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
                
                mapWindows[index].title = "Cerulean - Metra \(service.apiRepresentation()) train \(trainNumber) to \(service.getDestination(trainString: trainNumber))"
                
                self.mapWindows[index].contentView = MTMapView(train: placemark, station: stopMark, timeLastUpdated: dateFormatter.string(from: Date()))
                self.mapWindows[index].center()
                self.mapWindows[index].setIsVisible(true)
                self.mapWindows[index].orderFrontRegardless()
                self.mapWindows[index].makeKey()
                NSApp.activate(ignoringOtherApps: true)
            } else if let trainNumber = sender.trainNumber, let service = sender.service {
                placemark.service = service
                placemark.trainNumber = trainNumber
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.current)
                
                mapWindows[index].title = "Cerulean - Metra \(service.apiRepresentation()) train \(trainNumber) to \(service.getDestination(trainString: trainNumber))"
                
                self.mapWindows[index].contentView = MTMapView(train: placemark, timeLastUpdated: dateFormatter.string(from: Date()))
                self.mapWindows[index].center()
                self.mapWindows[index].setIsVisible(true)
                self.mapWindows[index].orderFrontRegardless()
                self.mapWindows[index].makeKey()
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        mapMutex.unlock()
    }
    
    @objc func openDebugMapWindow(_ sender: CRMenuItem) {
        mapMutex.lock()
        if let screenSize = NSScreen.main?.frame.size {
            let window = NSWindow(contentRect: NSMakeRect(0, 0, screenSize.width * 0.5, screenSize.height * 0.5), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            let index = mapWindows.count
            mapWindows.append(window)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.timeZone = TimeZone.autoupdatingCurrent
            
            let timeLastUpdated = formatter.string(from: Date())
            
            mapWindows[index].title = "Cerulean"
            mapWindows[index].contentView = CRDMapView(timeLastUpdated: timeLastUpdated)
            mapWindows[index].center()
            mapWindows[index].setIsVisible(true)
            mapWindows[index].orderFrontRegardless()
            mapWindows[index].makeKey()
            NSApp.activate(ignoringOtherApps: true)
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
