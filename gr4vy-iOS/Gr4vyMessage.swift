//
//  Gr4vyMessage.swift
//  gr4vy-iOS
//
//  Created by Gr4vy
//

import Foundation

struct Gr4vyMessage {
    var type: String
    var payload: [String: Any]
    
    enum Gr4vyMessageType: String {
        // Embed UI → Embed
        case frameReady
        case approvalUrl
        case transactionCreated
        // Embed → Embed UI
        case approvalErrored
        case transactionUpdated
        case transactionFailed
        // Other
        case navigation
        case openLink
        // Apple pay
        case appleStartSession
        case appleCompletePayment
    }
}
