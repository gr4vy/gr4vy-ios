//
//  Gr4vyCartItem.swift
//  gr4vy-ios
//

import Foundation

public struct Gr4vyCartItem: Codable {
    let name: String
    let quantity: Int
    let unitAmount: Int
    let discountAmount: Int?
    let taxAmount: Int?
    var externalIdentifier:String? = nil
    var sku: String? = nil
    var productUrl: String? = nil
    var imageUrl: String? = nil
    var categories: [String]? = nil
    var productType: String? = nil
    var sellerCountry: String? = nil
    
    public init(name: String, quantity: Int, unitAmount: Int, discountAmount: Int? = 0, taxAmount: Int? = 0,
                externalIdentifier: String? = nil, sku: String? = nil, productUrl: String? = nil, imageUrl: String? = nil, categories: [String]? = nil, productType: String? = nil, sellerCountry: String? = nil) {
        self.name = name
        self.quantity = quantity
        self.unitAmount = unitAmount
        self.discountAmount = discountAmount
        self.taxAmount = taxAmount
        self.externalIdentifier = externalIdentifier
        self.sku = sku
        self.productUrl = productUrl
        self.imageUrl = imageUrl
        self.categories = categories
        self.productType = productType
        self.sellerCountry = sellerCountry
    }
}
