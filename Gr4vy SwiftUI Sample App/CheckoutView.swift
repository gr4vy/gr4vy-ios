//
//  CheckoutView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI
import gr4vy_iOS

struct CheckoutView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    @State var presentingModal = false
    @State var outcome: Outcome = Outcome.success
    
    var body: some View {
        
        // TODO: Set your own token, buyerID and gr4vyID here
        let token = "<TOKEN HERE>"
        let buyerId = "<BUYER ID HERE>"
        let gr4vyId = "<GR4VY ID HERE>"
        
        let gr4vy = Gr4vy(gr4vyId: gr4vyId,
                          token: token,
                          amount: 10873,
                          currency: UserDefaults.standard.object(forKey:"Currency") as! String,
                          country: "GB",
                          buyerId: buyerId,
                          environment: .sandbox,
                          onEvent: { event in
            switch event {
            case .transactionFailed(let transactionID, let status, let paymentMethodID):
                print("Handle transactionFailed here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown")")
                outcome = .failure(reason: "transactionFailed")
                presentingModal = true
            case .transactionCreated(let transactionID, let status, let paymentMethodID):
                print("Handle transactionCreated here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown")")
                outcome = .success
                presentingModal = true
            case .generalError(let error):
                print("Error: \(error.description)")
                outcome = .failure(reason: error.description)
                presentingModal = true
            case .paymentMethodSelected(let id, let method, let mode):
                print("Handle a change in payment method selected here, ID: \(id ?? "Unknown"), Method: \(method), Mode: \(mode)")
                return
            }
        })
        NavigationView {
            VStack {
                ProductDetailView(product: Product(title: "T-shirt", price: "69.99", image: "TShirt"))
                
                ProductDetailView(product: Product(title: "Backpack", price: "34.99", image: "Backpack"))
                Button(action: {
                    self.viewControllerHolder?.present(style: .fullScreen) {
                        gr4vy?.view()
                    }
                }) {
                    Text("Checkout")
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(RoundedRectangle(cornerRadius: 10   , style: .continuous)
                    .fill(Color.blue))
                .padding()
                .sheet(isPresented: $presentingModal) {
                    OutcomeView(presentedAsModal: self.$presentingModal, outcome: outcome)
                }
            }
            .navigationTitle("Checkout")
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            ).padding()
        }
    }
}

struct Product: Identifiable {
    let id = UUID()
    let title: String
    let price: String
    let image: String
}

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        HStack {
            Image(product.image)
            Text(product.title)
                .font(.title2)
            Text(product.price)
                .font(.title2)
        }
        .frame(
            maxWidth: .infinity
        )
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
        
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "dismissModal"), object: nil, queue: nil) { [weak toPresent] _ in
            toPresent?.dismiss(animated: true, completion: nil)
        }
        self.present(toPresent, animated: true, completion: nil)
    }
}
