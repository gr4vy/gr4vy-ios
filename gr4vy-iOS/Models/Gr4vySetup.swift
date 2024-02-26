//
//  Gr4vySetup.swift
//  gr4vy-ios
//

import Foundation

struct Gr4vySetup: Encodable {
    var gr4vyId: String
    var token: String
    var amount: Int
    var currency: String
    var country: String
    var buyerId: String?
    var environment: Gr4vyEnvironment
    var externalIdentifier: String?
    var store: Gr4vyStore?
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
    var merchantAccountId: String?
    var connectionOptions: [String: [String: Gr4vyConnectionOptionsValue]]?
    var apiHost: String?
    var apiUrl: String?
    var supportedApplePayVersion: Int = 0
    var instance: String {
        return environment == .production ? gr4vyId : "sandbox.\(gr4vyId)"
    }
    
    enum CodingKeys: String, CodingKey {
        case token
        case amount
        case currency
        case country
        case buyerId
        case externalIdentifier
        case store
        case display
        case intent
        case metadata
        case paymentSource
        case cartItems
        case theme
        case buyerExternalIdentifier
        case locale
        case statementDescriptor
        case requireSecurityCode
        case shippingDetailsId
        case merchantAccountId
        case connectionOptions
        case apiHost
        case apiUrl
        case supportedApplePayVersion
    }
    
    public init(gr4vyId: String, token: String, amount: Int, currency: String, country: String, buyerId: String? = nil, environment: Gr4vyEnvironment, externalIdentifier: String? = nil, store: Gr4vyStore? = nil, display: String? = nil, intent: String? = nil, metadata: [String : String]? = nil, paymentSource: Gr4vyPaymentSource? = nil, cartItems: [Gr4vyCartItem]? = nil, applePayMerchantId: String? = nil, theme: Gr4vyTheme? = nil, buyerExternalIdentifier: String? = nil, locale: String? = nil, statementDescriptor: Gr4vyStatementDescriptor? = nil, requireSecurityCode: Bool? = nil, shippingDetailsId: String? = nil, merchantAccountId: String? = nil, connectionOptions: [String: [String: Gr4vyConnectionOptionsValue]]? = nil) {
        self.gr4vyId = gr4vyId
        self.token = token
        self.amount = amount
        self.currency = currency
        self.country = country
        self.buyerId = buyerId
        self.environment = environment
        self.externalIdentifier = externalIdentifier
        self.store = store
        self.display = display
        self.intent = intent
        self.metadata = metadata
        self.paymentSource = paymentSource
        self.cartItems = cartItems
        self.applePayMerchantId = applePayMerchantId
        self.theme = theme
        self.buyerExternalIdentifier = buyerExternalIdentifier
        self.locale = locale
        self.statementDescriptor = statementDescriptor
        self.requireSecurityCode = requireSecurityCode
        self.shippingDetailsId = shippingDetailsId
        self.merchantAccountId = merchantAccountId
        self.connectionOptions = connectionOptions
    }
}
