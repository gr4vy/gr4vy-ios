//
//  Gr4vyBuyer.swift
//  gr4vy-ios
//

import Foundation

public struct Gr4vyBuyer: Codable {
    let displayName: String?
    let externalIdentifier: String?
    let billingDetails: Gr4vyBillingDetails?
    let shippingDetails: Gr4vyShippingDetails?
    
    public init(
        displayName: String? = nil,
        externalIdentifier: String? = nil,
        billingDetails: Gr4vyBillingDetails? = nil,
        shippingDetails: Gr4vyShippingDetails? = nil
    ) {
        self.displayName = displayName
        self.externalIdentifier = externalIdentifier
        self.billingDetails = billingDetails
        self.shippingDetails = shippingDetails
    }
}

public struct Gr4vyBillingDetails: Codable {
    let firstName: String?
    let lastName: String?
    let emailAddress: String?
    let phoneNumber: String?
    let address: Gr4vyAddress?
    let taxId: Gr4vyTaxId?

    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        emailAddress: String? = nil,
        phoneNumber: String? = nil,
        address: Gr4vyAddress? = nil,
        taxId: Gr4vyTaxId? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.address = address
        self.taxId = taxId
    }
}

public struct Gr4vyShippingDetails: Codable {
    let firstName: String?
    let lastName: String?
    let emailAddress: String?
    let phoneNumber: String?
    let address: Gr4vyAddress?

    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        emailAddress: String? = nil,
        phoneNumber: String? = nil,
        address: Gr4vyAddress? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.address = address
    }
}

public struct Gr4vyAddress: Codable {
    let houseNumberOrName: String?
    let line1: String?
    let line2: String?
    let organization: String?
    let city: String?
    let postalCode: String?
    let country: String?
    let state: String?
    let stateCode: String?

    public init(
        houseNumberOrName: String? = nil,
        line1: String? = nil,
        line2: String? = nil,
        organization: String? = nil,
        city: String? = nil,
        postalCode: String? = nil,
        country: String? = nil,
        state: String? = nil,
        stateCode: String? = nil
    ) {
        self.houseNumberOrName = houseNumberOrName
        self.line1 = line1
        self.line2 = line2
        self.organization = organization
        self.city = city
        self.postalCode = postalCode
        self.country = country
        self.state = state
        self.stateCode = stateCode
    }
}

public struct Gr4vyTaxId: Codable {
    let value: String?
    let kind: String?

    public init(
        value: String? = nil,
        kind: String? = nil
    ) {
        self.value = value
        self.kind = kind
    }
}
