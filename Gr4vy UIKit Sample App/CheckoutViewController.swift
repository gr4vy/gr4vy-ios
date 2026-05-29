//
//  CheckoutViewController.swift
//  Gr4vy UIKit Sample App
//
//  Created by Gr4vy
//

import UIKit
import gr4vy_ios

class CheckoutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Checkout"
        
    }
    
    @IBAction func checkout(_ sender: Any) {
        
        // TODO: Set your own token and gr4vyID here
        let token = "eyJ0eXAiOiJKV1QiLCJraWQiOiJ4S1NGUnFBSFFSN2JkWHkwbHFEamRBanpGM0xEc01xbk56X041T3hNVHRBIiwiYWxnIjoiRVM1MTIifQ.eyJpc3MiOiJodHRwczovL2FwaS5zcGlkZXIuZ3I0dnkuYXBwLyIsImF1ZCI6Imh0dHBzOi8vYXBpLnNwaWRlci5ncjR2eS5hcHAvIiwianRpIjoiZTYwNjFiNmUtNTk2YS00YzhhLTkxMTUtODJkMGEwOWMxNDQ3Iiwic3ViIjoiMTA4M2NjOGItMGM0OC00NzkwLTlhM2UtOWNlNWM3NjU1YTI1OjAiLCJleHAiOjE3ODAwNzQwMDcsIm5iZiI6MTc4MDA3MzcwNywiaWF0IjoxNzgwMDczNzA3LCJzY29wZXMiOlsiKi5yZWFkIiwiKi53cml0ZSIsImFwaS1rZXktcGFpcnMucmVhZCIsImFwaS1rZXktcGFpcnMud3JpdGUiLCJoZWFsdGgtZGFzaGJvYXJkLnJlYWQiLCJoZWFsdGgtZGFzaGJvYXJkLndyaXRlIiwibWV0cmljcy1leHBsb3Jlci5yZWFkIiwibWV0cmljcy1leHBsb3Jlci53cml0ZSIsIm1vbml0b3JpbmcucmVhZCIsIm1vbml0b3Jpbmcud3JpdGUiLCJwYXltZW50LWxpbmtzLnJlYWQiLCJzZXNzaW9ucy53cml0ZSIsInVzZXJzLm1lLnJlYWQiLCJ1c2Vycy5tZS53cml0ZSIsInVzZXJzLnJlYWQiLCJ1c2Vycy53cml0ZSJdLCJpc19zdGFmZiI6ZmFsc2V9.AQiXBXAAS-_bT644TIpZtEH3fmTUN6XiN6nQNbJTBvwSN9kFzUcOf06Mc_WeijnEKACLo5yW0Lh4JNlUQGEo3g5lAG8CytLVlVz8Pv_2glOKxMvY70NqyYxXlRY3Y8obTpuEZnt6IUngD8mHzwFTZPKqyRRHpMQAudQHQ_amcjqdQf1r"
        let gr4vyId = "spider"
        
        var categories = [String]()
        categories.append("test")
        categories.append("checkout")
        var items = [Gr4vyCartItem]()
        items.append(Gr4vyCartItem(name: "Baklava's", quantity: 1, unitAmount: 10000, discountAmount: 100, categories: categories))
        
        guard let gr4vy = Gr4vy(gr4vyId: gr4vyId,
                                token: token,
                                amount: 10873,
                                currency: "USD",
                                country: "US",
                                store: .false,
                                cartItems: items,
                                environment: .sandbox,
                                theme: Gr4vyTheme(fonts: Gr4vyFonts(body: "google:Lato, Tahoma, Arial"),
                                                  colors: Gr4vyColours(text: "#fff",
                                                                       subtleText: "#a1b0bd",
                                                                       labelText: "#fff",
                                                                       primary: "#fff",
                                                                       pageBackground: "#1d334b",
                                                                       containerBackgroundUnchecked: "#1d334b",
                                                                       containerBackground: "#2c4765",
                                                                       containerBorder: "#304c6a",
                                                                       inputBorder: "#f2f2f2",
                                                                       inputBackground: "#2a4159",
                                                                       inputText: "#fff",
                                                                       danger: "#ff556a",
                                                                       dangerBackground: "#2c4765",
                                                                       dangerText: "#fff",
                                                                       info: "#3ea2ff",
                                                                       infoBackground: "#e7f2fb",
                                                                       infoText: "#0367c4",
                                                                       focus: "#4844ff",
                                                                       headerText: "#ffffff",
                                                                       headerBackground: "#2c4765"),
                                                  borderWidths: Gr4vyBorderWidths(container: "thin", input: "thin"),
                                                  radii: Gr4vyRadii(container: "subtle", input: "subtle"),
                                                  shadows: Gr4vyShadows(focusRing: "0 0 0 2px #ffffff, 0 0 0 4px #4844ff")),
                                                 requireSecurityCode: true,
                                                  connectionOptions:[
                                                    "forter-anti-fraud": [
                                                        "is_guest_buyer": .bool(true)]],
                                
                                                  debugMode: true
        ) else {
            print("Unable to load Gr4vy")
            return
        }
        
        gr4vy.launch(
            presentingViewController: self,
            onEvent: { event in
                let outcomeViewController = OutcomeViewController(nibName: "OutcomeViewController",
                                                                  bundle:  nil)
                switch event {
                case .transactionFailed(let transactionID, let status, let paymentMethodID, _):
                    print("Handle transactionFailed here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown")")
                    outcomeViewController.outcome = .failure(reason: "transactionFailed")
                case .transactionCreated(let transactionID, let status, let paymentMethodID, let approvalUrl):
                    print("Handle transactionCreated here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown"), approvalUrl: \(approvalUrl ?? "Unknown")")
                    outcomeViewController.outcome = .success
                case .generalError(let error):
                    print("Error: \(error.description)")
                    outcomeViewController.outcome = .failure(reason: error.description)
                case .cancelled:
                    print("User cancelled")
                    return
                case .cardDetailsChanged(let bin, let cardType, let scheme):
                    print("Card details changed, BIN: \(bin), Card Type: \(cardType), Scheme: \(scheme ?? "Unknown")")
                    return
                }
                
                self.present(outcomeViewController, animated: true, completion: nil)
            })
    }
}
