//
//  OutcomeView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI

struct OutcomeView: View {
    
    @Binding var presentedAsModal: Bool
    var outcome: Outcome
    
    var body: some View {
        
        let content = outcome.content()
        
        VStack(alignment: .center, spacing: 20) {
            if let imageResource = content.imageResource {
                Image(uiImage: imageResource)
            }
            Text(content.title).font(.title2)
            Text(content.subtitle).font(.title2).bold()
            Text(content.description).font(.title2)
            
            Button(action: {
                self.presentedAsModal = false
            }) {
                Text("Continue Shopping")
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.blue))
            .padding()
        }
    }
}

struct OutcomeView_Previews: PreviewProvider {
    
    @State var presentingModal = false
    static var previews: some View {
        OutcomeView(presentedAsModal: .constant(true), outcome: .success)
    }
}

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
