//
//  Gr4vyCartItem.swift
//  gr4vy-ios
//

import Foundation

public struct Gr4vyCartItem {
    let name: String
    let quantity: Int
    let unitAmount: Int
    
    public init(name: String, quantity: Int, unitAmount: Int) {
        self.name = name
        self.quantity = quantity
        self.unitAmount = unitAmount
    }
}
