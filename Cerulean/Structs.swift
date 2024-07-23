//
//  Structs.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/23/24.
//

import SwiftUI
import Foundation

enum Line {
    case red
    case blue
    case green
    case brown
    case orange
    case pink
    case purple
    case purpleExpress
    case yellow
    
    func textualRepresentation() -> String {
        switch self {
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        case .green:
            return "Green"
        case .brown:
            return "Brown"
        case .orange:
            return "Orange"
        case .pink:
            return "Pink"
        case .purple:
            return "Purple"
        case .purpleExpress:
            return "Purple Express"
        case .yellow:
            return "Yellow"
        }
    }
    
    func apiRepresentation() -> String {
        switch self {
        case .red:
            return "Red"
        case .blue:
            return "Blue"
        case .green:
            return "G"
        case .brown:
            return "Brn"
        case .orange:
            return "Org"
        case .pink:
            return "Pink"
        case .purple:
            return "P"
        case .purpleExpress:
            return "Pexp"
        case .yellow:
            return "Y"
        }
    }
    
    func barIndex() -> Int {
        switch self {
        case .red:
            return 0
        case .blue:
            return 1
        case .green:
            return 2
        case .brown:
            return 3
        case .orange:
            return 4
        case .pink:
            return 5
        case .purple:
            return 6
        case .purpleExpress:
            return 6
        case .yellow:
            return 7
        }
    }
}
