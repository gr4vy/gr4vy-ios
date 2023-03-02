//
//  Gr4vyViewController.swift
//  gr4vy-iOS
//
//  Created by Gr4vy
//

import Foundation
import UIKit
import SwiftUI
import PassKit

public enum Gr4vyEvent: Equatable {
    case transactionCreated(transactionID: String, status: String, paymentMethodID: String?)
    case transactionFailed(transactionID: String, status: String, paymentMethodID: String?)
    case paymentMethodSelected(id: String?, method: String, mode: String)
    case generalError(String)
}

public enum Gr4vyEnvironment {
    case sandbox
    case production
}

public typealias Gr4vyCompletionHandler = (Gr4vyEvent) -> ()

public class Gr4vy {
    
    private var rootViewController: Gr4vyViewController!
    private var popUpViewController: Gr4vyViewController?
    private var setup: Gr4vySetup!
    private var debugMode: Bool = false
    
    public var onEvent: Gr4vyCompletionHandler?
    
    public init?(gr4vyId: String,
                 token: String,
                 amount: Int,
                 currency: String,
                 country: String,
                 buyerId: String?,
                 externalIdentifier: String? = nil,
                 store: String? = nil,
                 display: String? = nil,
                 intent: String? = nil,
                 metadata: [String: String]? = nil,
                 paymentSource: Gr4vyPaymentSource? = nil,
                 cartItems: [Gr4vyCartItem]? = nil,
                 environment: Gr4vyEnvironment = .production,
                 applePayMerchantId: String? = nil,
                 debugMode: Bool = false,
                 onEvent: Gr4vyCompletionHandler? = nil) {
        
        self.setup = Gr4vySetup(gr4vyId: gr4vyId,
                                token: token,
                                amount: amount,
                                currency: currency,
                                country: country,
                                buyerId: buyerId,
                                environment: environment,
                                externalIdentifier: externalIdentifier,
                                store: store,
                                display: display,
                                intent: intent,
                                metadata: metadata,
                                paymentSource: paymentSource,
                                cartItems: cartItems,
                                applePayMerchantId: applePayMerchantId)
        
        self.debugMode = debugMode
        self.onEvent = onEvent
        
        guard let url = Gr4vyUtility.getInitialURL(from: setup) else {
            dismissWithEvent(.generalError("Gr4vy Error: Failed to load"))
            return nil
        }
        
        rootViewController = Gr4vyViewController()
        rootViewController.delegate = self
        rootViewController.url = url
    }
    
    public func launch(presentingViewController: UIViewController,
                       onEvent: Gr4vyCompletionHandler? = nil) {
        
        self.onEvent = onEvent
        
        guard let url = Gr4vyUtility.getInitialURL(from: setup) else {
            dismissWithEvent(.generalError("Gr4vy Error: Failed to load"))
            return
        }
        
        rootViewController = Gr4vyViewController()
        rootViewController.delegate = self
        rootViewController.url = url
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.modalPresentationStyle = .overFullScreen
        
        presentingViewController.present(navigationController, animated: true, completion: nil)
    }
    
    
    @ViewBuilder
    public func view() -> some View {
        ViewControllerWrapper(rootViewController: rootViewController)
    }
    
    public struct ViewControllerWrapper: UIViewControllerRepresentable {
        
        let rootViewController: Gr4vyViewController
        
        public func makeUIViewController(context: Context) -> UINavigationController {
            return UINavigationController(rootViewController: rootViewController)
        }
        
        public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    }
}

extension Gr4vy: Gr4vyInternalDelegate {
    
    func dismissWithEvent(_ event: Gr4vyEvent) {
        
        // If the popUpViewController is not shown/created, just dismiss the rootViewController
        guard let popUpViewController = popUpViewController else {
            self.rootViewController.dismiss(animated: true) {
                self.onEvent?(event)
            }
            return
        }
        
        // Otherwise dismiss the the popUpViewController and the rootViewController
        popUpViewController.dismiss(animated: true, completion: {
            self.rootViewController.dismiss(animated: true) {
                self.onEvent?(event)
            }
        })
    }
    
    func error(message: String) {
        if debugMode {
            Gr4vyLogger.log(message)
        }
    }
    
    func handle(message: Gr4vyMessage) {
        guard let messageType = Gr4vyMessage.Gr4vyMessageType(rawValue: message.type) else {
            error(message: "Gravy Information: Unknown message type recieved.")
            return
        }
        
        switch messageType {
            
            // Root Only
        case .frameReady:
            rootViewController.sendJavascriptMessage(Gr4vyUtility.generateUpdateOptions(from: setup)) { _, _ in }
            return
            
            // Root Only
        case .approvalUrl:
            guard let url = Gr4vyUtility.handleApprovalUrl(from: message.payload) else {
                dismissWithEvent(.generalError("Gr4vy Error: Approval URL Failure"))
                return
            }
            
            popUpViewController = Gr4vyViewController()
            popUpViewController!.delegate = self
            popUpViewController!.url = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            
            let nav = UINavigationController(rootViewController: popUpViewController!)
            nav.modalPresentationStyle = .overFullScreen
            
            rootViewController.present(nav, animated: true, completion: nil)
            return
            
            // Root Only
        case .transactionCreated:
            dismissWithEvent(Gr4vyUtility.handleTransactionCreated(from: message.payload))
            return
        case .transactionFailed:
            error(message: "Gr4vy Error: transaction Failed")
            error(message: "\(message.payload.debugDescription)")
            dismissWithEvent(.generalError("Gr4vy Error: transaction Failed"))
            return
            
            // Popover Only
        case .transactionUpdated, .approvalErrored:
            guard let content = Gr4vyUtility.handleTransactionUpdated(from: message.payload) else {
                dismissWithEvent(.generalError("Gr4vy Error: transactionUpdated / approvalErrored pass through failed. "))
                return
            }
            
            rootViewController.sendJavascriptMessage(content) { _, _ in }
            popUpViewController!.dismiss(animated: true, completion: nil)
            return
            
        case .paymentMethodSelected:
            guard let message = Gr4vyUtility.handlePaymentSelected(from: message.payload) else {
                error(message: "Gr4vy Error: paymentMethodSelected failure")
                return
            }
            
            self.onEvent?(message)
            return
            
            // Apple Pay
        case .appleStartSession:
            guard let merchantId = setup.applePayMerchantId else {
                error(message: "Gr4vy Error: Apple Pay session error - No Merchant ID set in SDK Setup")
                return
            }
            
            guard let request = handleAppleStartSession(message: message, merchantId: merchantId) else {
                error(message: "Gr4vy Error: Apple Pay session error")
                return
            }
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                error(message: "Gr4vy Error: This device does not support Apple Pay")
                return
            }
            rootViewController.applePayState = .started
            
            paymentVC.delegate = rootViewController
            rootViewController.present(paymentVC, animated: true, completion: nil)
            
            return
            
        case .appleCompletePayment:
            rootViewController.applePayState = .started
            self.rootViewController.sendJavascriptMessage(Gr4vyUtility.generateAppleCompleteSession()) { _, _ in }
        }
    }
    
    func handleAppleStartSession(message: Gr4vyMessage, merchantId: String) -> PKPaymentRequest? {
        return Gr4vyUtility.handleAppleStartSession(from: message.payload, merchantId: merchantId)
    }
    
    func generateApplePayAuthorized(payment: PKPayment) {
        rootViewController.sendJavascriptMessage(Gr4vyUtility.generateApplePayAuthorized(from: payment)) { _, _ in }
    }
    
    func handleAppleCancelSession() {
        rootViewController.sendJavascriptMessage(Gr4vyUtility.generateAppleCancelSession()) { _, _ in }
    }
}

protocol Gr4vyInternalDelegate {
    func handle(message: Gr4vyMessage)
    func handleAppleStartSession(message: Gr4vyMessage, merchantId: String) -> PKPaymentRequest?
    func generateApplePayAuthorized(payment: PKPayment)
    func handleAppleCancelSession()
    func error(message: String)
}

struct Gr4vySetup {
    var gr4vyId: String
    var token: String
    var amount: Int
    var currency: String
    var country: String
    var buyerId: String?
    var environment: Gr4vyEnvironment
    var externalIdentifier: String?
    var store: String?
    var display: String?
    var intent: String?
    var metadata: [String: String]?
    var paymentSource: Gr4vyPaymentSource?
    var cartItems: [Gr4vyCartItem]?
    var applePayMerchantId: String?
    var instance: String {
        return environment == .production ? gr4vyId : "sandbox.\(gr4vyId)"
    }
}

public enum Gr4vyPaymentSource: String {
    case installment
    case recurring
}

public struct Gr4vyCartItem {
    let name: String
    let quantity: Int
    let unitAmount: Int
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}

struct ApplePayPayment: Codable {
    let paymentData: ApplePayPaymentTokenData // Codable
    let paymentMethod: ApplePayPaymentMethod // Codable
    let transactionIdentifier: String
    
    init?(token: PKPaymentToken) {
        guard let paymentData = ApplePayPaymentTokenData(data: token.paymentData),
              let paymentMethod = ApplePayPaymentMethod(paymentMethod: token.paymentMethod) else {
            return nil
        }
        self.paymentData = paymentData
        self.paymentMethod = paymentMethod
        self.transactionIdentifier = token.transactionIdentifier
    }
}

struct ApplePayPaymentMethod: Codable {
    let displayName: String
    let network: String
    let type: String
    let methodType: Int
    
    init?(paymentMethod: PKPaymentMethod) {
        self.type = paymentMethod.type.description
        self.displayName = paymentMethod.displayName ?? "unknown"
        self.network = paymentMethod.network?.rawValue ?? "unknown"
        self.methodType = Int(paymentMethod.type.rawValue)
    }
}

extension PKPaymentMethodType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .credit: return "credit"
        case .debit: return "debit"
        case .prepaid: return "prepaid"
        case .store: return "store"
        case .eMoney: return "eMoney"
        default:
            return "unknown"
        }
    }
}

struct ApplePayPaymentTokenData: Codable {
    let data: String
    let header: [String: String]
    let version: String
    let signature: String
    
    init?(data: Data) {
        guard let paymentData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [AnyHashable: AnyHashable] else {
            return nil
        }
        guard let rawData = paymentData["data"] as? String,
              let rawHeader = paymentData["header"] as? [String: String],
              let rawVersion = paymentData["version"] as? String,
              let rawSignature = paymentData["signature"] as? String else {
            return nil
        }
        self.data = rawData
        self.header = rawHeader
        self.version = rawVersion
        self.signature = rawSignature
        
    }
}

struct ApplePayPaymentTokenDataHeader: Codable {
    let publicKeyHash, ephemeralPublicKey, transactionID: String
    
    enum CodingKeys: String, CodingKey {
        case publicKeyHash, ephemeralPublicKey
        case transactionID = "transactionId"
    }
}


