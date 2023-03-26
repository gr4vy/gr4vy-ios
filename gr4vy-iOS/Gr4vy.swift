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
                 buyerId: String? = nil,
                 externalIdentifier: String? = nil,
                 store: String? = nil,
                 display: String? = nil,
                 intent: String? = nil,
                 metadata: [String: String]? = nil,
                 paymentSource: Gr4vyPaymentSource? = nil,
                 cartItems: [Gr4vyCartItem]? = nil,
                 environment: Gr4vyEnvironment = .production,
                 applePayMerchantId: String? = nil,
                 theme: Gr4vyTheme? = nil,
                 buyerExternalIdentifier: String? = nil,
                 locale: String? = nil,
                 statementDescriptor: Gr4vyStatementDescriptor? = nil,
                 requireSecurityCode: Bool? = nil,
                 shippingDetailsId: String? = nil,
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
                                theme: theme,
                                buyerExternalIdentifier: buyerExternalIdentifier,
                                locale: locale,
                                statementDescriptor: statementDescriptor,
                                requireSecurityCode: requireSecurityCode,
                                shippingDetailsId: shippingDetailsId)
        
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
            popUpViewController!.theme = setup.theme
            
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
    
    func handleApprovalCancelled() {
        rootViewController.sendJavascriptMessage(Gr4vyUtility.generateApprovalCancelled()) { _, _ in }
    }
}

protocol Gr4vyInternalDelegate {
    func handle(message: Gr4vyMessage)
    func handleAppleStartSession(message: Gr4vyMessage, merchantId: String) -> PKPaymentRequest?
    func generateApplePayAuthorized(payment: PKPayment)
    func handleAppleCancelSession()
    func handleApprovalCancelled()
    func error(message: String)}

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
    var theme: Gr4vyTheme?
    var buyerExternalIdentifier: String?
    var locale: String?
    var statementDescriptor: Gr4vyStatementDescriptor?
    var requireSecurityCode: Bool?
    var shippingDetailsId: String?
    var instance: String {
        return environment == .production ? gr4vyId : "sandbox.\(gr4vyId)"
    }
}

public struct Gr4vyTheme {
    
    let fonts: Gr4vyFonts?
    let colors: Gr4vyColours?
    let borderWidths: Gr4vyBorderWidths?
    let radii: Gr4vyRadii?
    let shadows: Gr4vyShadows?
    var navigationBackgroundColor: UIColor? {
        guard let headerBackground = colors?.headerBackground else {
            return nil
        }
        return hexStringToUIColor(hex: headerBackground)
    }
    var navigationTextColor: UIColor? {
        guard let headerText = colors?.headerText else {
            return nil
        }
        return hexStringToUIColor(hex: headerText)
    }
    
    public init(fonts: Gr4vyFonts? = nil, colors: Gr4vyColours? = nil, borderWidths: Gr4vyBorderWidths? = nil, radii: Gr4vyRadii? = nil, shadows: Gr4vyShadows? = nil) {
        self.fonts = fonts
        self.colors = colors
        self.borderWidths = borderWidths
        self.radii = radii
        self.shadows = shadows
    }
    
    func toString() -> String {
        var data = ""
        
        if let fonts = fonts, let body = fonts.body {
            data = data + "'fonts': { 'body': '\(body)' }, "
        }
        
        if let colors = colors {
            
            data = data + "'colors': {"
            
            let mirror = Mirror(reflecting: colors)
            for child in mirror.children  {
                if let key = child.label, let value = child.value as? String {
                    data = data + "'\(key)': '\(value)', "
                }
            }
            
            data = data + "}, "
        }
        
        if let borderWidths = borderWidths {
            data = data + "'borderWidths': {"
            
            if let input = borderWidths.input {
                data = data + "'input': '\(input)', "
            }
            if let container = borderWidths.container {
                data = data + "'container': '\(container)', "
            }
            
            data = data + "}, "
        }
        
        if let radii = radii {
            data = data + "'radii': {"
            
            if let input = radii.input {
                data = data + "'input': '\(input)', "
            }
            if let container = radii.container {
                data = data + "'container': '\(container)', "
            }
            
            data = data + "}, "
        }
        
        if let shadows = shadows, let focusRing = shadows.focusRing {
            data = data + "'shadows': { 'focusRing': '\(focusRing)' },"
        }
        
        return "{" + data + "}"
    }
    
    private func hexStringToUIColor (hex:String) -> UIColor? {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return nil
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

public struct Gr4vyFonts {
    let body: String?
    
    public init(body: String? = nil) {
        self.body = body
    }
}

public struct Gr4vyColours {
    let text: String?
    let subtleText: String?
    let labelText: String?
    let primary: String?
    let pageBackground: String?
    let containerBackgroundUnchecked: String?
    let containerBackground: String?
    let containerBorder: String?
    let inputBorder: String?
    let inputBackground: String?
    let inputText: String?
    let inputRadioBorder: String?
    let inputRadioBorderChecked: String?
    let danger: String?
    let dangerBackground: String?
    let dangerText: String?
    let info: String?
    let infoBackground: String?
    let infoText: String?
    let focus: String?
    let headerText: String?
    let headerBackground: String?
    
    public init(text: String? = nil, subtleText: String? = nil, labelText: String? = nil, primary: String? = nil, pageBackground: String? = nil, containerBackgroundUnchecked: String? = nil, containerBackground: String? = nil, containerBorder: String? = nil, inputBorder: String? = nil, inputBackground: String? = nil, inputText: String? = nil, inputRadioBorder: String? = nil, inputRadioBorderChecked: String? = nil, danger: String? = nil, dangerBackground: String? = nil, dangerText: String? = nil, info: String? = nil, infoBackground: String? = nil, infoText: String? = nil, focus: String? = nil, headerText: String? = nil, headerBackground: String? = nil) {
        self.text = text
        self.subtleText = subtleText
        self.labelText = labelText
        self.primary = primary
        self.pageBackground = pageBackground
        self.containerBackgroundUnchecked = containerBackgroundUnchecked
        self.containerBackground = containerBackground
        self.containerBorder = containerBorder
        self.inputBorder = inputBorder
        self.inputBackground = inputBackground
        self.inputText = inputText
        self.inputRadioBorder = inputRadioBorder
        self.inputRadioBorderChecked = inputRadioBorderChecked
        self.danger = danger
        self.dangerBackground = dangerBackground
        self.dangerText = dangerText
        self.info = info
        self.infoBackground = infoBackground
        self.infoText = infoText
        self.focus = focus
        self.headerText = headerText
        self.headerBackground = headerBackground
    }
}

public struct Gr4vyBorderWidths {
    let container: String?
    let input: String?
    
    public init(container: String? = nil, input: String? = nil) {
        self.container = container
        self.input = input
    }
}

public struct Gr4vyRadii {
    let container: String?
    let input: String?
    
    public init(container: String? = nil, input: String? = nil) {
        self.container = container
        self.input = input
    }
}

public struct Gr4vyShadows {
    let focusRing: String?
    
    public init(focusRing: String? = nil) {
        self.focusRing = focusRing
    }
}

public struct Gr4vyStatementDescriptor {
    let name: String?
    let description: String?
    let phoneNumber: String?
    let city: String?
    let url: String?
    
    public init(name: String? = nil, description: String? = nil, phoneNumber: String? = nil, city: String? = nil, url: String? = nil) {
        self.name = name
        self.description = description
        self.phoneNumber = phoneNumber
        self.city = city
        self.url = url
    }
    
    func toString() -> String {
        var data = ""
        
        if let name = name {
            data = data + "'name': '\(name)', "
        }
        if let description = description {
            data = data + "'description': '\(description)', "
        }
        if let phoneNumber = phoneNumber {
            data = data + "'phoneNumber': '\(phoneNumber)', "
        }
        if let city = city {
            data = data + "'city': '\(city)', "
        }
        if let url = url {
            data = data + "'url': '\(url)', "
        }
        
        return "{" + data + "}"
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


