//
//  Gr4vyViewController.swift
//  gr4vy-iOS
//
//  Created by Gr4vy
//

import Foundation
import UIKit
import SafariServices
import SwiftUI
import PassKit

public enum Gr4vyEvent: Equatable {
    case transactionCreated(transactionID: String, status: String, paymentMethodID: String?, approvalUrl: String?)
    case transactionFailed(transactionID: String, status: String, paymentMethodID: String?)
    case cancelled
    case generalError(String)
}

public enum Gr4vyEnvironment: String, Codable {
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
                 buyerId: String? = nil,
                 externalIdentifier: String? = nil,
                 store: Gr4vyStore? = nil,
                 display: String? = nil,
                 intent: String? = nil,
                 metadata: [String: String]? = nil,
                 paymentSource: Gr4vyPaymentSource? = nil,
                 cartItems: [Gr4vyCartItem]? = nil,
                 environment: Gr4vyEnvironment = .production,
                 applePayMerchantId: String? = nil,
                 applePayMerchantName: String? = nil, 
                 theme: Gr4vyTheme? = nil,
                 buyerExternalIdentifier: String? = nil,
                 locale: String? = nil,
                 statementDescriptor: Gr4vyStatementDescriptor? = nil,
                 requireSecurityCode: Bool? = nil,
                 shippingDetailsId: String? = nil,
                 merchantAccountId: String? = nil,
                 connectionOptions: [String: [String: Gr4vyConnectionOptionsValue]]? = nil,
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
                                applePayMerchantId: applePayMerchantId,
                                applePayMerchantName: applePayMerchantName,
                                theme: theme,
                                buyerExternalIdentifier: buyerExternalIdentifier,
                                locale: locale,
                                statementDescriptor: statementDescriptor,
                                requireSecurityCode: requireSecurityCode,
                                shippingDetailsId: shippingDetailsId,
                                merchantAccountId: merchantAccountId,
                                connectionOptions: connectionOptions)
        
        self.debugMode = debugMode
        self.onEvent = onEvent
        
        guard let url = Gr4vyUtility.getInitialURL(from: setup) else {
            dismissWithEvent(.generalError("Gr4vy Error: Failed to load"))
            return nil
        }
        
        rootViewController = Gr4vyViewController()
        rootViewController.delegate = self
        rootViewController.url = url
        rootViewController.theme = theme
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
        rootViewController.theme = setup.theme
        
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
            guard let _ = rootViewController else {
                self.onEvent?(event)
                return
            }
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
    
    func handle(message: Gr4vyMessage, viewType: Gr4vyViewType) {
        guard let messageType = Gr4vyMessage.Gr4vyMessageType(rawValue: message.type) else {
            error(message: "Gr4vy Information: Unknown message type recieved. \(message.type)")
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
            popUpViewController?.viewType = .popUp
            popUpViewController!.delegate = self
            popUpViewController!.url = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            popUpViewController!.theme = setup.theme
            
            let nav = UINavigationController(rootViewController: popUpViewController!)
            nav.modalPresentationStyle = .overFullScreen

            rootViewController.present(nav, animated: true, completion: nil)
            return
            
            // Root Only
        case .transactionCreated:
            let message = Gr4vyUtility.handleTransactionCreated(from: message.payload)
            switch message {
                case .transactionCreated:
                    dismissWithEvent(message)
                    return
                default:
                    self.onEvent?(message)
            }
            return
        case .transactionFailed:
            error(message: "Gr4vy Error: transaction Failed")
            error(message: "\(message.payload.debugDescription)")
            self.onEvent?(Gr4vyUtility.handleTransactionFailed(from: message.payload))
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
        
        case .navigation:
            guard let navigationUpdate = Gr4vyUtility.handleNavigationUpdate(from: message.payload) else {
                error(message: "Gr4vy Error: navigation parse failure")
                return
            }
            
            switch viewType {
            case .popUp:
                popUpViewController?.title = navigationUpdate.title
                popUpViewController?.setBackButton(isEnabled: navigationUpdate.canGoBack)
            case .root:
                rootViewController.title = navigationUpdate.title
                rootViewController.setBackButton(isEnabled: navigationUpdate.canGoBack)
            }
            
            return
        
        case .openLink:
            guard let url = Gr4vyUtility.handleOpenLink(from: message.payload) else {
                error(message: "Gr4vy Error: Open link URL not valid")
                return
            }
            switch viewType {
            case .popUp:
                popUpViewController?.present(SFSafariViewController(url: url), animated: true)
            case .root:
                rootViewController?.present(SFSafariViewController(url: url), animated: true)
            }
            return
            
            // Apple Pay
        case .appleStartSession:
            guard let merchantId = setup.applePayMerchantId else {
                error(message: "Gr4vy Error: Apple Pay session error - No Merchant ID set in SDK Setup")
                return
            }
            
            guard let request = handleAppleStartSession(message: message, merchantId: merchantId, merchantName: setup.applePayMerchantName) else {
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
    
    func handleAppleStartSession(message: Gr4vyMessage, merchantId: String, merchantName: String? = nil) -> PKPaymentRequest? {
        return Gr4vyUtility.handleAppleStartSession(from: message.payload, merchantId: merchantId, merchantName: merchantName)
    }
    
    func generateApplePayAuthorized(payment: PKPayment) {
        rootViewController.sendJavascriptMessage(Gr4vyUtility.generateApplePayAuthorized(from: payment)) { _, _ in }
    }
    
    func handleAppleCancelSession() {
        rootViewController.sendJavascriptMessage(Gr4vyUtility.generateAppleCancelSession()) { _, _ in }
    }
    
    func handleApprovalCancelled() {
        rootViewController.sendJavascriptMessage(Gr4vyUtility.generateApprovalCancelled()) { _, _ in }
    }
    
    func handleBackButtonPressed() {
        rootViewController.sendJavascriptMessage(Gr4vyUtility.generateNavigationBack()) { _, _ in }
    }
    
    func handleCancelled(viewType: Gr4vyViewType) {
        if viewType == .root {
            self.onEvent?(.cancelled)
        }
    }
}

protocol Gr4vyInternalDelegate {
    func handle(message: Gr4vyMessage, viewType: Gr4vyViewType)
    func handleAppleStartSession(message: Gr4vyMessage, merchantId: String, merchantName: String?) -> PKPaymentRequest?
    func generateApplePayAuthorized(payment: PKPayment)
    func handleAppleCancelSession()
    func handleApprovalCancelled()
    func handleBackButtonPressed()
    func handleCancelled(viewType: Gr4vyViewType)
    func error(message: String)
}
