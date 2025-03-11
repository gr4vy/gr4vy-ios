# Gr4vy iOS SDK

![Build Status](https://github.com/gr4vy/gr4vy-ios/actions/workflows/ios.yml/badge.svg?branch=main)

[![Swift](https://img.shields.io/badge/Swift-5.3_5.4_5.5-orange?style=for-the-badge)](https://img.shields.io/badge/Swift-5.3_5.4_5.5-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=for-the-badge)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_Linux_Windows-Green?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/gr4vy-ios.svg?style=for-the-badge)](https://img.shields.io/cocoapods/v/gr4vy-ios.svg)

Quickly embed Gr4vy in your iOS app to store card details, authorize payments, and capture a transaction.

## Installation

gr4vy-ios doesn't contain any external dependencies.

### Minimum Deployment Level

> **Note**:
> The minimum deployment level required for this SDK is `14.0`

### CocoaPods

[CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate gr4vy-ios into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'gr4vy-ios', '2.3.0'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

or for M1 Macs:

```bash
$ arch -x86_64 pod install
```

## Get started

To use Gr4vy Embed, import the library and call the `.launch()` method.

```swift
import gr4vy_ios
```

### UIKit

```swift
let gr4vy = Gr4vy(gr4vyId: "[GR4VY_ID]",
                  token: "[TOKEN]",
                  amount: 1299,
                  currency: "USD",
                  country: "US",
                  applePayMerchantId: "[APPLE_PAY_MERCHANTID]" // Optional, ensure this is added to enable Apple Pay
)

gr4vy?.launch(
    presentingViewController: self,
    onEvent: { event in
        switch event {
        case .transactionFailed(let transactionID, let status, let paymentMethodID):
            print("Handle transactionFailed here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown")")
            return
        case .transactionCreated(let transactionID, let status, let paymentMethodID, let approvalUrl):
            print("Handle transactionCreated here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown"), approvalUrl: \(approvalUrl ?? "Unknown")")
            return
        case .generalError(let error):
            print("Error: \(error.description)")
            return
        }
    })
```

### SwiftUI

```swift
let gr4vy = Gr4vy(gr4vyId: "[GR4VY_ID]",
                  token: "[TOKEN]",
                  amount: 1299,
                  currency: "USD",
                  country: "USD",
                  applePayMerchantId: "[APPLE_PAY_MERCHANTID]" // Optional, ensure this is added to enable Apple Pay
                  onEvent: { event in
    switch event {
    case .transactionFailed(let transactionID, let status, let paymentMethodID):
        print("Handle transactionFailed here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown")")
        return
    case .transactionCreated(let transactionID, let status, let paymentMethodID, let approvalUrl):
        print("Handle transactionCreated here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown"), approvalUrl: \(approvalUrl ?? "Unknown")")
        return
    case .generalError(let error):
        print("Error: \(error.description)")
        return
    }
})

// Then whenever the view is needed:
gr4vy?.view()
```

> **Note**:
> Replace `"[GR4VY_ID]"` with the ID of your instance.
> Replace `"[TOKEN]"` with your JWT access token (See any of our [server-side SDKs](https://github.com/gr4vy?q=sdk) for more details.).
> Replace `"[APPLE_PAY_MERCHANTID]"` with the merchant ID registered for the bundle ID you want to use.
> `presentingViewController` is the current view controller this SDK is launched from. gr4vy-ios presents on top of the current view controller, passing events via the `onEvent` callback.

### Options

These are the parameteres available on the `launch` method:


| Field                     | Optional / Required    | Description                                                                                                                                                                                                                                                                                                                               |
| ------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `gr4vyId`                 | **`Required`**      | The Gr4vy ID automatically sets the `apiHost` to `api.<gr4vyId>.gr4vy.app` for production and `api.sandbox.<gr4vyId>.gr4vy.app` and  to `embed.sandbox.<gr4vyId>.gr4vy.app` for the sandbox environment.|
| `token`                   | **`Required`**      | The server-side generated JWT token used to authenticate any of the API calls.|
| `amount`                  | **`Required`**      | The amount to authorize or capture in the specified `currency` only.|                                                                                   |
| `currency`                | **`Required`**      | A valid, active, 3-character `ISO 4217` currency code to authorize or capture the `amount` for.|
| `country`                 | **`Required`**      | A valid `ISO 3166` country code.|
| `buyerId`                 | `Optional`      | An optional ID for a Gr4vy buyer. The transaction will automatically be associated to a buyer with that ID. If no buyer with this ID exists then it will be ignored.|
| `presentingViewController`| **`Required`**       | The view controller presenting the Gr4vy flow. |
| `externalIdentifier`      | `Optional`      | An optional external identifier that can be supplied. This will automatically be associated to any resource created by Gr4vy and can subsequently be used to find a resource by that ID. |
| `store`                   | `Optional`       | `'ask'`, `'preselect'`, `true`, `false` - Explicitly store the payment method, ask the buyer or preselect it by default. Requires `buyerId` or `buyerExternalIdentifier`. |
| `display`                 | `Optional`       | `all`, `addOnly`, `storedOnly`, `supportsTokenization` - Filters the payment methods to show stored methods only, new payment methods only or methods that support tokenization.
| `intent`                  | `Optional` | `authorize`, `preferAuthorize`, `capture` - Defines the intent of this API call. This determines the desired initial state of the transaction. When used, `preferAuthorize` automatically switches to `capture` if the selected payment method doesn't support delayed capture.|
| `metadata`                | `Optional` | An optional dictionary of key/values for transaction metadata. All values should be a string.|
| `paymentSource`           | `Optional` | `installment`, `recurring` - Can be used to signal that Embed is used to capture the first transaction for a subscription or an installment. When used, `store` is implied to be `true` and `display` is implied to be `supportsTokenization`. This means that payment options that do not support tokenization are automatically hidden. |
| `cartItems`               | `Optional` | An optional array of cart item objects, each object must define a `name`, `quantity`, and `unitAmount`. Other optional properties are `discountAmount`, `taxAmount`, `externalIdentifier`, `sku`, `productUrl`, `imageUrl`, `categories`, `productType` and `sellerCountry`.|
| `environment`| `Optional`       | `.sandbox`, `.production`. Defaults to `.production`. When `.sandbox` is provided the URL will contain `sandbox.GR4VY_ID`. |
| `applePayMerchantId`| `Optional`       | The Apple merchant ID to be used during Apple Pay transcations |
| `applePayMerchantName`| `Optional`       | The name which appears in the Apple Pay dialog next to "Pay" |
| `theme`| `Optional`       | Theme customisation options. See [Theming](https://github.com/gr4vy/gr4vy-embed/tree/main/packages/embed#theming). The iOS SDK also contains an additional two properties within the `colors` object; `headerBackground` and `headerText`. These are used for the navigation background and forground colors. |
| `buyerExternalIdentifier`| `Optional`       | An optional external ID for a Gr4vy buyer. The transaction will automatically be associated to a buyer with that external ID. If no buyer with this external ID exists then it will be ignored. This option is ignored if the `buyerId` is provided. |
| `locale`| `Optional`       | An optional locale, this consists of a `ISO 639 Language Code` followed by an optional `ISO 3166 Country Code`, e.g. `en`, `en-gb` or `pt-br`. |
| `statementDescriptor`| `Optional`       | An optional object with information about the purchase to construct the statement information the buyer will see in their bank statement. Please note support for these fields varies across payment service providers and underlying banks, so Gr4vy can only ensure a best effort approach for each supported platform. As an example, most platforms will only support a concatenation of `name` and `description` fields, this is truncated to a length of 22 characters within embed. The object can contain `name`, `description`, `phoneNumber`, `city` and `url` properties, with string values. `phoneNumber` should be in E164 format. Gr4vy recommends avoiding characters outside the alphanumeric range and the dot (`.`) to ensure wide compatibility. |
| `requireSecurityCode`| `Optional`       | An optional boolean which forces security code to be prompted for stored card payments. |
| `shippingDetailsId`| `Optional`       | An optional unique identifier of a set of shipping details stored for the buyer. |
| `merchantAccountId`| `Optional`       | An optional merchant account ID. |
| `connectionOptions`| `Optional`       | An optional set of options passed to a connection when processing a transaction (see https://docs.gr4vy.com/reference#operation/authorize-new-transaction) |
| `connectionOptionsString`| `Optional`       | A JSON String of connectionOptions |
| `buyer`| `Optional`       | An optional buyer object to allow guest checkout (see https://docs.gr4vy.com/reference/transactions/new-transaction) |
| `debugMode`| `Optional`       | `true`, `false`. Defaults to `false`, this prints to the console. |
| `onEvent`                 | `Optional`      | **Please see below for more details.** |

### OnEvent

The `onEvent` option can be used to listen to certain events emitted from the SDK.

```swift
onEvent: { event in
 switch event {
 case .transactionFailed(let transactionID, let status, let paymentMethodID):
     print("Handle transactionFailed here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown")")
     return
 case .transactionCreated(let transactionID, let status, let paymentMethodID, let approvalUrl):
     print("Handle transactionCreated here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID ?? "Unknown"), approvalUrl: \(approvalUrl ?? "Unknown")")
     return
 case .generalError(let error):
     print("Error: \(error.description)")
     return
 case .cancelled:
     print("User cancelled")
     return
 }
```

gr4vy-ios emits the following events:

#### `transactionCreated`

Returns a data about the transaction object when the transaction was successfully created.

```json
{
  "transactionID": "8724fd24-5489-4a5d-90fd-0604df7d3b83",
  "status": "pending",
  "paymentMethodID": "17d57b9a-408d-49b8-9a97-9db382593003",
  "approvalUrl": "https://example.com"
}
```

#### `transactionFailed`

Returned when the transaction encounters an error.

```json
{
  "transactionID": "8724fd24-5489-4a5d-90fd-0604df7d3b83",
  "status": "pending",
  "paymentMethodID": "17d57b9a-408d-49b8-9a97-9db382593003"
}
```

#### `generalError`

Returned when the SDK encounters an error.

```json
{
  "Gr4vy Error: Failed to load"
}
```

#### `cancelled`

Returned when the user cancels the SDK.


### Apple Pay

To enable Apple Pay in your iOS project, you will need to pass the configured `applePayMerchantId` to the SDK in the `Gr4vy.init()` call. In addition you'll need to enable Apple Pay within the `Signing & Capabilities` Xcode project settings and set the Apple Pay `Merchant IDs` (NOTE: ensure your provisioning profiles and signing certificates are updated to contain this valid Apple Merchant ID). The SDK will do various checks to ensure the device is capable of Apple Pay and will be enabled if both the device and merchant ID is valid.

## License

This project is provided as-is under the [MIT license](LICENSE).
