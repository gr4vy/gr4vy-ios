//
//  Gr4vyStore.swift
//  gr4vy-ios
//

import Foundation

public enum Gr4vyStore {
    case ask
    case `true`
    case `false`
    
    func getStringRepresentation() -> String {
        switch self {
        case .ask:
            return "'ask'"
        case .true:
            return "true"
        case .false:
            return "false"
        }
    }
}
