//
//  AppDelegate.swift
//  Gr4vy UIKit Sample App
//
//  Created by Gr4vy
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        // Set the default currency
        UserDefaults.standard.set("GBP", forKey: "Currency")

        if #available(iOS 13.0, *) {
            // Do nothing, handled by SceneDelegate
        } else {
            // Set up the window for iOS 12 and earlier
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController()!
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }

        return true
    }
}

