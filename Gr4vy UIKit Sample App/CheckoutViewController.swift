//
//  CheckoutViewController.swift
//  Gr4vy UIKit Sample App
//
//  Created by Gr4vy
//

import UIKit
import gr4vy_iOS

class CheckoutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Checkout"
    }

    @IBAction func checkout(_ sender: Any) {
        
        // TODO: Set your own token, buyerID and gr4vyID here
        let token = "<TOKEN HERE>"
        let buyerId = "<BUYER ID HERE>"
        let gr4vyId = "<GR4VY ID HERE>"
        
        Gr4vy.shared.launch(gr4vyId: gr4vyId,
                           token: token,
                           amount: 10873,
                           currency: UserDefaults.standard.object(forKey:"Currency") as! String,
                           country: "GB",
                           buyerId: buyerId,
                           presentingViewController: self,
                           environment: .sandbox,
                           onEvent: { event in
                            let outcomeViewController = OutcomeViewController(nibName: "OutcomeViewController",
                                                                              bundle:  nil)
                            switch event {
                            case .transactionFailed(let transactionID, let status, let paymentMethodID):
                                print("Handle transactionFailed here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID)")
                                outcomeViewController.outcome = .failure(reason: "transactionFailed")
                            case .transactionCreated(let transactionID, let status, let paymentMethodID):
                                print("Handle transactionCreated here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID)")
                                outcomeViewController.outcome = .success
                            case .generalError(let error):
                                outcomeViewController.outcome = .failure(reason: error.description)
                            case .paymentMethodSelected(let id, let method, let mode):
                                print("Handle a change in payment method selected here, ID: \(id), Method: \(method), Mode: \(mode)")
                                return
                            }
                            
                            self.present(outcomeViewController, animated: true, completion: nil)
        })
    }
}
