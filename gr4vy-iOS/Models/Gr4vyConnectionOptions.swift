//
//  Gr4vyConnectionOptions.swift
//  gr4vy-ios
//
//

import Foundation

public struct Gr4vyConnectionOptions {
    var data: [String: [String: Any]]
    
    public init(data: [String : [String : Any]]) {
        self.data = data
    }
    
    var convertedString: String? {
        
        guard !data.isEmpty else {
            return nil
        }
         let jsonData: Data
         do {
             jsonData = try JSONSerialization.data(withJSONObject: data)
         } catch {
             return nil
         }
        
         
        if !jsonData.isEmpty, let jsonString = String(data: jsonData, encoding: .utf8), !jsonString.isEmpty {
             return jsonString.replacingOccurrences(of: "\"", with: "'")
         } else {
             return nil
         }
     }
}
