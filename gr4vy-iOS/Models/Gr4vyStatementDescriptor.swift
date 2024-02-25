//
//  Gr4vyStatementDescriptor.swift
//  gr4vy-ios
//

import Foundation

public struct Gr4vyStatementDescriptor: Codable {
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
}
