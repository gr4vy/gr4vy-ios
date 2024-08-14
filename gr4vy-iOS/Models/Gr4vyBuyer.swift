//
//  Gr4vyBuyer.swift
//  gr4vy-ios
//

import Foundation

public struct Gr4vyBuyer: Codable {
    let displayName: String?
    let externalIdentifier: String?
    let billingDetails: Gr4vyBillingDetails?
    let shippingDetails: Gr4vyBillingDetails?
    
    public init(displayName: String? = nil, externalIdentifier: String? = nil, billingDetails: Gr4vyBillingDetails? = nil, shippingDetails: Gr4vyBillingDetails? = nil) {
        self.displayName = displayName
        self.externalIdentifier = externalIdentifier
        self.billingDetails = billingDetails
        self.shippingDetails = shippingDetails
    }
}

public struct Gr4vyBillingDetails: Codable {
    let firstName: String?
    
    public init(firstName: String? = nil) {
        self.firstName = firstName
    }
}
