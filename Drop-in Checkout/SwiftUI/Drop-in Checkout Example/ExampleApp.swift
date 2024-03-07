//
//  Co_Badged_Cards_ExampleApp.swift
//  Drop-in Checkout Example
//
//  Created by Jack Newcombe on 24/10/2023.
//

import SwiftUI
import UIKit
import PrimerSDK

@main
struct ExampleApp: App {

    // 📚 To get started with Drop-in checkout, check out our guide (hold ⌘ and click the link)
    // https://primer.io/docs/payments/universal-checkout/drop-in/get-started/ios

    // 👇 You can put a valid client token here, or define it in the Settings Page of the app
    static var clientToken = ""
    
    // 👇 You can point to a server that provides the client token here
    static var clientTokenUrl = "https://my.glitch.server/"
    
    let service = PrimerDataService(clientToken: Self.clientToken)
        
    init() {
        PrimerLogging.shared.logger.logLevel = .debug
        Appearance.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack {
                    ContentView(service: service)
                }
                StatusBarShim()
            }
        }
    }
}
