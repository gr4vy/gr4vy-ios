//
//  Gr4vyStatementDescriptor.swift
//  gr4vy-ios
//

import Foundation

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
