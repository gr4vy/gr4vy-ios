# Gr4vy iOS SDK

![Build Status](https://github.com/gr4vy/gr4vy-ios/actions/workflows/ios.yml/badge.svg?branch=main)

[![Swift](https://img.shields.io/badge/Swift-5.3_5.4_5.5-orange?style=for-the-badge)](https://img.shields.io/badge/Swift-5.3_5.4_5.5-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=for-the-badge)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_Linux_Windows-Green?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/gr4vy-ios.svg?style=for-the-badge)](https://img.shields.io/cocoapods/v/gr4vy-ios.svg)

Quickly embed Gr4vy in your iOS app to store card details,
authorize payments, and capture a transaction.

## Installation

gr4vy-ios doesn't contain any external dependencies.

### CocoaPods

[CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate gr4vy-ios into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'gr4vy-ios', '1.2.0'
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
import gr4vy_iOS
```

```swift
Gr4vy.shared.launch(gr4vyId: [GR4VY_ID],
                           token: [TOKEN],
                           amount: 1299,
                           currency: "USD",
                           country: "US",
                           presentingViewController: self,
                           onEvent: { event in
                            // Handle the events sent via Gr4vy. See below.
        })
```

> **Note**: 
> Replace `[GR4VY_ID]` with the ID of your instance. 
> Replace `[TOKEN]` with your JWT access token (See any of our [server-side SDKs](https://github.com/gr4vy?q=sdk) for more details.). 
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
| `store`                   | `Optional`       | `'ask'`, `true`, `false` - Explicitly store the payment method or ask the buyer, this is used when a buyerId is provided.|
| `display`                 | `Optional`       | `all`, `addOnly`, `storedOnly`, `supportsTokenization` - Filters the payment methods to show stored methods only, new payment methods only or methods that support tokenization.
| `intent`                  | `Optional` | `authorize`, `capture` - Defines the intent of this API call. This determines the desired initial state of the transaction.|
| `metadata`                | `Optional` | An optional dictionary of key/values for transaction metadata. All values should be a string.|
| `paymentSource`           | `Optional` | `installment`, `recurring` - Can be used to signal that Embed is used to capture the first transaction for a subscription or an installment. When used, `store` is implied to be `true` and `display` is implied to be `supportsTokenization`. This means that payment options that do not support tokenization are automatically hidden. |
| `cartItems`               | `Optional` | An optional array of cart item objects, each object must define a `name`, `quantity`, and `unitAmount`.|
| `environment`| `Optional`       | `.sandbox`, `.production`. Defaults to `.production`. When `.sandbox` is provided the URL will contain `sandbox.GR4VY_ID`. |
| `debugMode`| `Optional`       | `true`, `false`. Defaults to `false`, this prints to the console. |
| `onEvent`                 | `Optional`      | **Please see below for more details.** |


### OnEvent

The `onEvent` option can be used to listen to certain events emitted from the SDK.

```swift
Gr4vy.shared.launch(gr4vyId: [GR4VY_ID],
                            ...
                           onEvent: { event in
                            switch event {
                              case .transactionFailed(let transactionID, let status, let paymentMethodID):
                                  // Handle transactionFailed here
                                  print("Handle transactionFailed here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID)")
                                  return
                              case .transactionCreated(let transactionID, let status, let paymentMethodID):
                                  // Handle transactionCreated here
                                  print("Handle transactionCreated here, ID: \(transactionID), Status: \(status), PaymentMethodID: \(paymentMethodID)")
                                  return
                              case .generalError(let error):
                                  // Handle generalError here
                                  print("Handle generalError here")
                              case .paymentMethodSelected(let id, let method, let mode):
                                  // Handle a change in payment method selected here
                                  print("Handle a change in payment method selected here, ID: \(id), Method: \(method), Mode: \(mode)")
                                  return
                            }
        })
```

gr4vy-ios emits the following events:

#### `transactionCreated`

Returns a data about the transaction object when the transaction was successfully created.

```json
{
  "transactionID": "8724fd24-5489-4a5d-90fd-0604df7d3b83",
  "status": "pending",
  "paymentMethodID": "17d57b9a-408d-49b8-9a97-9db382593003"
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

#### `paymentMethodSelected`

Returned when the user selects a payment method.

```json
{
  "id": "17d57b9a-408d-49b8-9a97-9db382593003",
  "method": "card",
  "mode": "card"
}
```

## License

This project is provided as-is under the [MIT license](LICENSE).
