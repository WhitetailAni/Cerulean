//
//  AppDelegate.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import Cocoa
import AppKit
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var progressIndicator: NSProgressIndicator!
    var menu: NSMenu!
    
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
                                    let inputFormatter = DateFormatter()
                                    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                    inputFormatter.timeZone = TimeZone(identifier: "America/Chicago")
                                    let timeToArrive: Date = inputFormatter.date(from: station["nextStationArrivalTime"] ?? "") ?? Date(timeIntervalSince1970: 0)
                                    let outputFormatter = DateFormatter()
                                    outputFormatter.dateFormat = "HH:mm"
                                    outputFormatter.timeZone = TimeZone.autoupdatingCurrent
                                    
                                    let subSubItem = NSMenuItem(title: "\(station["nextStation"] ?? "Unknown station") at \(outputFormatter.string(from: timeToArrive))", action: nil, keyEquivalent: "")
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
    
    @objc func nop() { }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}

