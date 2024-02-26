//
//  Gr4vyStore.swift
//  gr4vy-ios
//

import Foundation

public enum Gr4vyStore: Codable {
    case ask
    case `true`
    case `false`
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .ask:
            try container.encode("ask")
        case .true:
            try container.encode(true)
        case .false:
            try container.encode(false)
        }
    }
}
