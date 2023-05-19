//
//  UIImage+Extensions.swift
//  gr4vy-ios
//

import UIKit

extension UIImage {
    /// Creates an image object using the named image asset from the current library bundle.
    static func fetchGr4vyImage(named: String) -> UIImage? {
        let bundle: Bundle?
        
        if let bundlePath = Bundle(for: Gr4vy.self).path(forResource: "gr4vy-ios-Assets", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        } else {
            bundle = Bundle(for: Gr4vy.self)
        }
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
}
