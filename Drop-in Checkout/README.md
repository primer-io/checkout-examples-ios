# 📲 Drop-in Checkout Example

This example demonstrates how to integrate drop-in checkout into your iOS app.

## Getting Started

To run the example app:

1. Clone the repo:

```sh
git clone https://github.com/primer-io/checkout-examples-ios.git
```

2. Change directory into the repo

```sh
cd "checkout-examples-ios/Drop-in Checkout/SwiftUI"
```

3. Open the project

```sh
open "Drop-in Checkout Example.xcodeproj"
```

4. Run the project from Xcode 🚀

----

This project requires a server to communicate with Primer's API. To get started quickly, we encourage you to use the [companion backend](https://github.com/primer-io/checkout-example-backend).

## Trying it out

This example app allows you to:

- Generate a client token
- Make a payment with one of your configured payment methods, using drop-in checkout

For card payments, we support several test cards for different cases. You can find these in our docs:

📄 **[Primer Payments Testing](https://primer.io/docs/payments/testing)**

## Understanding the integration

### PrimerDataService

This class contains all the business logic required to interact with the Primer SDK and start making payments.

This class is intended to be a `kitchen sink` that shows the whole integration in one place. You can use it to bootstrap your own integration.

### ExampleApp

This class contains two static properties that are used to auto-fill settings. You can get a head start by providing a client token or a URL for an endpoint serving client tokens directly in the code.

If you don't provide these, you can provide them on the app's start page once it's launched.

### ExampleAppLogger

This is a logger used to print useful messages during app execution.

You can find these logs by filtering on `[Drop-in Checkout Example App]` in the Xcode debug console.
