//
//  CheckoutView.swift
//  Gr4vy SwiftUI Sample App
//
//

import SwiftUI
import gr4vy_ios

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
                          onEvent: { event in
            switch event {
            case .transactionFailed(let transactionID, let status, let paymentMethodID):
                print("Handle transactionFailed here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown")")
                outcome = .failure(reason: "transactionFailed")
                presentingModal = true
                return
            case .transactionCreated(let transactionID, let status, let paymentMethodID):
                print("Handle transactionCreated here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown")")
                outcome = .success
                presentingModal = true
                return
            case .generalError(let error):
                print("Error: \(error.description)")
                outcome = .failure(reason: error.description)
                presentingModal = true
                return
            case .cancelled:
                print("User cancelled")
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
