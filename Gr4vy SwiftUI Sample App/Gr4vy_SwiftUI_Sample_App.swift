//
//  Gr4vy_SwiftUI_Sample_App.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UserDefaults.standard.set("GBP", forKey: "Currency")
        return true
    }
}


@main
struct Gr4vy_SwiftUI_Sample_App: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            CheckoutView()
        }
    }
}
