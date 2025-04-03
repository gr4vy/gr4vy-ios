//
//  Gr4vyUtility.swift
//  gr4vy-iOS
//
//  Created by Gr4vy
//

import Foundation
import PassKit

struct Gr4vyUtility {
    
    static func getInitialURL(from setup: Gr4vySetup) -> URLRequest? {
        guard !setup.gr4vyId.isEmpty else { return nil }
        let urlString = "https://embed.\(setup.instance).gr4vy.app/mobile?channel=123"
        guard let url = URL(string: urlString) else {
            return nil
        }
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    static func getConnectionOptions(from connectionOptions: [String: [String: Gr4vyConnectionOptionsValue]]?, connectionOptionsString: String?) -> [String: [String: Gr4vyConnectionOptionsValue]]? {
        if let connectionOptions = connectionOptions {
            return connectionOptions
        }
        guard let connectionOptionsString else {
            return nil
        }
        
        typealias Gr4vyConnectionOptions = [String: [String: Gr4vyConnectionOptionsValue]]
        
        guard let data = connectionOptionsString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(Gr4vyConnectionOptions.self, from: data)
            return decodedData
        } catch {
            return nil
        }
    }
    
    
    static func generateUpdateOptions(from setup: Gr4vySetup) -> String {
        var mutableSetup = setup
        mutableSetup.apiHost = "api.\(setup.instance).gr4vy.app"
        mutableSetup.apiUrl = "https://api.\(setup.instance).gr4vy.app"
        
        if let applePayMerchantId = setup.applePayMerchantId, !applePayMerchantId.isEmpty {
            if deviceSupportsApplePay() {
                mutableSetup.supportedApplePayVersion = 5
            }
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        do {
            let jsonData = try encoder.encode(mutableSetup)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            
            let windowMessage = "window.postMessage({ \"channel\": 123, \"type\": \"updateOptions\", \"data\": \(jsonString)})"
            
            return windowMessage
        } catch {
            return ""
        }
    }
    
    static func generateAppleCompleteSession() -> String {
        return "window.postMessage({ channel: 123, type: 'appleCompleteSession'})"
    }
    
    static func generateAppleCancelSession() -> String {
        return "window.postMessage({ channel: 123, type: 'appleCancelSession'})"
    }
    
    static func generateApprovalCancelled() -> String {
        return "window.postMessage({ channel: 123, type: 'approvalCancelled'})"
    }
    
    static func generateNavigationBack() -> String {
        return "window.postMessage({ channel: 123, type: 'navigationBack'})"
    }
    
    static func handleNavigationUpdate(from payload: [String: Any]) -> NavigationUpdate? {
        guard let data = payload["data"] as? [String: Any],
              let title = data["title"] as? String,
              let canGoBack = data["canGoBack"] as? Bool else {
            return nil
        }
        return NavigationUpdate(title: title, canGoBack: canGoBack)
    }
    
    static func handleOpenLink(from payload: [String: Any]) -> URL? {
        guard let data = payload["data"] as? [String: Any],
              let urlString = data["url"] as? String else {
            return nil
        }
        
        return URL(string: urlString)
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
            return .generalError("Gr4vy Error: Pop up transaction created failed.")
        }
        
        switch status {
            // Success statuses
        case "capture_succeeded", "capture_pending", "authorization_succeeded", "authorization_pending", "processing":
            guard let transactionID = data["id"] as? String else {
                return .generalError("Gr4vy Error: transaction success has failed, no transactionID and/or paymentMethodID found")
            }
            let paymentMethod = data["paymentMethod"] as? [String: Any]
            let approvalUrl = paymentMethod?["approvalUrl"] as? String
            return .transactionCreated(transactionID: transactionID, status: status, paymentMethodID: data["paymentMethodID"] as? String, approvalUrl: approvalUrl)
            
            // Failure statuses
        case "capture_declined", "authorization_failed":
            return .transactionFailed(transactionID: data["id"] as? String ?? "", status: status, paymentMethodID: data["paymentMethodID"] as? String)
        default:
            return .transactionFailed(transactionID: data["id"] as? String ?? "", status: status, paymentMethodID: data["paymentMethodID"] as? String)
        }
    }
    
    static func handleTransactionFailed(from payload: [String: Any]) -> Gr4vyEvent {
        guard let data = payload["data"] as? [String: Any] else {
            return .generalError("Gr4vy Error: Transaction failed.")
        }
        let transactionID = data["id"] as? String ?? ""
        let status = data["status"] as? String ?? ""
        let paymentMethodID = data["paymentMethodID"] as? String
        let responseCode = data["responseCode"] as? String
        
        return .transactionFailed(transactionID: transactionID, status: status, paymentMethodID: paymentMethodID, responseCode: responseCode)
    }
    
    
    static func handleTransactionUpdated(from payload: [String: Any]) -> String? {
        guard let passOnMessage = try? JSONSerialization.data(withJSONObject: payload, options: .withoutEscapingSlashes), let message = String(data: passOnMessage, encoding: .utf8) else {
            return nil
        }
        
        return "window.postMessage(\(message.replacingOccurrences(of: "\"", with: "\"")))"
    }
    
    static func generateApplePayAuthorized(from payment: PKPayment) -> String {
        let token = payment.token.paymentData.prettyPrintedJSONString!.replacingOccurrences(of: "\n", with: "")
        let content =
        "window.postMessage({ channel: 123, type: 'applePayAuthorized', data: { 'payment_data': \(token) } })"
        return content
    }
    
    static func handleAppleStartSession(from payload: [String: Any], merchantId: String, merchantName: String?) -> PKPaymentRequest? {
        guard let data = payload["data"] as? [String: Any],
              let countryCode = data["countryCode"] as? String,
              let currencyCode = data["currencyCode"] as? String,
              let supportedNetworks = data["supportedNetworks"] as? [String],
              let total = data["total"] as? [String: Any],
              let value = merchantName ?? total["label"] as? String,
              let amount = total["amount"] as? String else {
            return nil
        }
        
        let paymentItem = PKPaymentSummaryItem.init(label: value, amount: NSDecimalNumber(string: amount))
        
        let networksMap: [String: PKPaymentNetwork] = [
            "amex": .amex,
            "cartesbancaires": .cartesBancaires,
            "discover": .discover,
            "eftpos": .eftpos,
            "electron": .electron,
            "elo": .elo,
            "interac": .interac,
            "jcb": .JCB,
            "mada": .mada,
            "maestro": .maestro,
            "mastercard": .masterCard,
            "privatelabel": .privateLabel,
            "visa": .visa,
            "vpay": .vPay
        ]
        
        let paymentNetworks = supportedNetworks.compactMap { network in
            networksMap[network.lowercased()]
        }
        
        let request = PKPaymentRequest()
        request.currencyCode = currencyCode
        request.countryCode = countryCode
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.merchantIdentifier = merchantId
        request.supportedNetworks = paymentNetworks
        request.paymentSummaryItems = [paymentItem]
        return request
        
    }
    
    static func deviceSupportsApplePay(paymentNetworks: [PKPaymentNetwork] = [PKPaymentNetwork.amex,
                                                                              PKPaymentNetwork.cartesBancaires,
                                                                              PKPaymentNetwork.discover,
                                                                              PKPaymentNetwork.eftpos,
                                                                              PKPaymentNetwork.electron,
                                                                              PKPaymentNetwork.elo,
                                                                              PKPaymentNetwork.interac,
                                                                              PKPaymentNetwork.JCB,
                                                                              PKPaymentNetwork.mada,
                                                                              PKPaymentNetwork.maestro,
                                                                              PKPaymentNetwork.masterCard,
                                                                              PKPaymentNetwork.privateLabel,
                                                                              PKPaymentNetwork.visa,
                                                                              PKPaymentNetwork.vPay]) -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks)
        
    }
    
    struct NavigationUpdate: Equatable {
        let title: String
        let canGoBack: Bool
    }
}
