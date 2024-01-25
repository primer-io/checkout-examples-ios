# 💳 Co-Badged Cards Example

This example demonstrates how to integrate support for co-badged cards in your iOS app.

## Getting Started

To run the example app:

1. Clone the repo:

```sh
git clone https://github.com/primer-io/checkout-examples-ios.git
```

2. Change the directory into the repo

```sh
cd "checkout-examples-ios/Co-Badged Cards/SwiftUI"
```

3. Open the project

```sh
open "Co-Badged Cards Example.xcodeproj"
```

4. Run the project from Xcode 🚀

----

This project requires a server to communicate with Primer's API. To get started quickly, we encourage you to use the [companion backend](https://github.com/primer-io/example-backend).

## Trying it out

This example app allows you to:

- Generate a client token
- Make a payment using a card
- Select a co-badged network when making a payment with a co-badged card

We support several test cards for different test cases, which you can find in our docs:

📄 **[Primer Payments Testing](https://primer.io/docs/payments/testing)**

## Understanding the integration

### PrimerDataService

This class contains all the business logic required to interact with the Primer SDK and start making payments.

This includes:
* SDK ininitialisation
* Handling of card validation via `PrimerHeadlessUniversalCheckoutRawDataManagerDelegate`
* Handling of payment submission via `PrimerHeadlessUniversalCheckoutDelegate`

This class is intended to be a `kitchen sink` that shows the whole integration in one place. You can use it to bootstrap your own integration.

### PrimerCardDataModel & PrimerCardDataErrorsModel

These models are used to reflect changes to user inputs via `CardDetailsFormView`.

The former is updated with user inputs as they are entered in to the form. 
The latter is updated with validation errors that are displayed in the form during entry.

### ExampleApp

This class contains two static properties that are used to auto-fill settings. You can get a head start by providing a client token or a URL for an endpoint serving client tokens directly in the code.

If you don't provide these, you can provide them on the app's start page once it's launched.

### ExampleAppLogger

This is a logger used to print useful messages during app execution.

You can find these logs by filtering on `[Co-Badged Cards Example App]` in the Xcode debug console.
