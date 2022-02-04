//
//  Gr4vyViewController.swift
//  gr4vy-iOS
//
//  Created by Gr4vy
//

import Foundation
import UIKit

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
    
    public static let shared = Gr4vy()
    
    private var rootViewController: Gr4vyViewController!
    private var popUpViewController: Gr4vyViewController?
    private var onEvent: Gr4vyCompletionHandler?
    private var setup: Gr4vySetup!
    private var debugMode: Bool = false

    public func launch(gr4vyId: String,
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
                      presentingViewController: UIViewController,
                      environment: Gr4vyEnvironment = .production,
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
                                cartItems: cartItems)
        
        self.onEvent = onEvent
        self.debugMode = debugMode
        
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
        }
    }
}

protocol Gr4vyInternalDelegate {
    func handle(message: Gr4vyMessage)
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
