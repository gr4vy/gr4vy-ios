//
//  OutcomeViewController.swift
//  Gr4vy UIKit Sample App
//
//  Created by Gr4vy
//

import UIKit

enum Outcome {
    case success
    case failure(reason: String)
}

struct OutcomeContent {
    var imageResource: UIImage? = #imageLiteral(resourceName: "Success")
    let title: String
    let subtitle: String
    let description: String
}

extension Outcome {
    func content() -> OutcomeContent {
        switch self {
        case .success:
            return OutcomeContent(title: "Success", subtitle: "Payment processed successfully", description: "This has the success state for a successful payment")
        case .failure(let reason):
            return OutcomeContent(imageResource: nil, title: "Error", subtitle: "Payment processed failed - \(reason)", description: "Please see the logs for more details")
        }
    }
}

class OutcomeViewController: UIViewController {
    
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    var outcome: Outcome = .success
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let content = outcome.content()
        
        resultImageView.image = content.imageResource
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
        descriptionLabel.text = content.description
    }

    @IBAction func `continue`(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
