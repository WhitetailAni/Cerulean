//
//  CeruleanApp.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit

class CeruleanApp: NSApplication {
    let delegate = AppDelegate()

    override init() {
        super.init()
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
