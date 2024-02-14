//
//  String+Extensions.swift
//  gr4vy-ios
//

import Foundation

extension String {
    func escapingJavaScriptCharacters() -> String {
        var escapedString = self
        // Replace single quotes
        escapedString = escapedString.replacingOccurrences(of: "\'", with: "\\\'")
        // Escape double quotes
        escapedString = escapedString.replacingOccurrences(of: "\"", with: "\\\"")
        // Newline
        escapedString = escapedString.replacingOccurrences(of: "\n", with: "\\n")
        // Carriage return
        escapedString = escapedString.replacingOccurrences(of: "\r", with: "\\r")
        return escapedString
    }
}
