//
//  Gr4vySetup.swift
//  gr4vy-ios
//

import Foundation

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
