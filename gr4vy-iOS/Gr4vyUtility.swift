//
//  Gr4vyUtility.swift
//  gr4vy-iOS
//
//  Created by Gr4vy
//

import Foundation

struct Gr4vyUtility {
    
    static func getInitialURL(from setup: Gr4vySetup) -> URLRequest? {
        let urlString = "https://embed.\(setup.instance).gr4vy.app/mobile.html?channel=123"
        guard let url = URL(string: urlString) else {
            return nil
        }
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    static func generateUpdateOptions(from setup: Gr4vySetup) -> String {
        var optionalData: String = ""
        
        if let externalIdentifier = setup.externalIdentifier {
            optionalData = optionalData + ", externalIdentifier: '\(externalIdentifier)'"
        }
        
        if let store = setup.store {
            optionalData = optionalData + ", store: '\(store)'"
        }
        
        if let display = setup.display {
            optionalData = optionalData + ", display: '\(display)'"
        }
        
        if let intent = setup.intent {
            optionalData = optionalData + ", intent: '\(intent)'"
        }
        
        let content =
        "window.postMessage({ type: 'updateOptions', data: { apiHost: 'api.\(setup.instance).gr4vy.app', apiUrl: 'https://api.\(setup.instance).gr4vy.app', buyerId: '\(setup.buyerId)', token: '\(setup.token)', amount: \(setup.amount), country: '\(setup.country)', currency: '\(setup.currency)'"
        +
        optionalData
        +
       "},})"
        
        return content
    }
    
    static func handleApprovalUrl(from payload: [String: Any]) -> URL? {
        guard let urlString = payload["data"] as? String else {
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
    
    static func handleTransactionCreated(from payload: [String: Any]) -> Gr4vyEvent {
        
        guard let data = payload["data"] as? [String: Any], let status = data["status"] as? String else {
            return .generalError("Gr4vy Error: Pop up transcation created failed.")
        }
        
        switch status {
        // Success statuses
        case "capture_succeeded", "capture_pending", "authorization_succeeded", "authorization_pending":
            return .transactionCreated(status: status)
            
        // Failure statuses
        case "capture_declined", "authorization_failed":
            guard let transactionID = data["transactionID"] as? String, let paymentMethodID = data["paymentMethodID"] as? String else {
                return .generalError("Gr4vy Error: transaction failed, no transactionID and/or paymentMethodID found")
            }
            return .transactionFailed(transactionID: transactionID, status: status, paymentMethodID: paymentMethodID)
        default:
            guard let transactionID = data["transactionID"] as? String, let paymentMethodID = data["paymentMethodID"] as? String else {
                return .generalError("Gr4vy Error: transaction failed, no transactionID and/or paymentMethodID found")
            }
            return .transactionFailed(transactionID: transactionID, status: status, paymentMethodID: paymentMethodID)
        }
    }
    
    static func handleTransactionUpdated(from payload: [String: Any]) -> String? {
        guard let passOnMessage = try? JSONSerialization.data(withJSONObject: payload, options: .withoutEscapingSlashes), let message = String(data: passOnMessage, encoding: .utf8) else {
            return nil
        }
        
        return "window.postMessage(\(message.replacingOccurrences(of: "\"", with: "\"")))"
    }
    
    static func handlePaymentSelected(from payload: [String: Any]) -> Gr4vyEvent? {
        guard let data = payload["data"] as? [String: String],
                let id = data["id"],
                let method = data["method"],
                let mode = data["mode"] else {
            return nil
        }
        
        return .paymentMethodSelected(id: id, method: method, mode: mode)
    }
}
