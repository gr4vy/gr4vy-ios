//
//  AppDelegate.swift
//  Gr4vy UIKit Sample App
//
//  Created by Gr4vy
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        // Set the default currency
        UserDefaults.standard.set("GBP", forKey: "Currency")
        return true
    }
}

