//
//  Gr4vyConnectionOptionsValue.swift
//  gr4vy-ios
//
//

import Foundation

public enum Gr4vyConnectionOptionsValue: Codable, Equatable {
    case string(String)
    case int(Int)
    case bool(Bool)
    case double(Double)
    case dictionary([String: String])
    
    private enum CodingError: Error {
        case unknownValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let dictionaryValue = try? container.decode([String: String].self) {
            self = .dictionary(dictionaryValue)
        } else {
            throw CodingError.unknownValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}
