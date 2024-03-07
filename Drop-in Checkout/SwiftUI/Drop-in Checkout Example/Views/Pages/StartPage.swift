//
//  StartPage.swift
//  Drop-in Checkout Example
//
//  Created by Jack Newcombe on 13/11/2023.
//

import SwiftUI
import PrimerSDK

enum SDKState {
    case inactive
    case configuring
    case ready
    case error
}

struct StartPage: View {
    
    @StateObject var settingsModel: SettingsModel

    @State var sdkState: SDKState = .inactive

    let delegateHandler = PrimerDelegateHandler()

    var body: some View {
        VStack {
            Form {
                FormInfo {
                    Text(LocalizedStringKey("Start.Text.Title")).font(.title)
                    Text(LocalizedStringKey("Start.Text.About")).font(.body).fontWeight(.light)
                }
                
                SettingsView(settingsModel: settingsModel)
                
                Section {
                    PrimerButton(action: { completion in
                        Primer.shared.showUniversalCheckout(clientToken: settingsModel.clientToken,
                                                            completion: { _ in completion() })
                    }, labelText: "Show checkout", isEnabled: isReadyForPaymentCreation)
//                    NavigationLink(destination: fullPageView) {
//                        if sdkState == .configuring {
//                            ButtonProgressView()
//                        } else {
//                            Text(LocalizedStringKey("Start.Button.MakePayment"))
//                                .frame(maxWidth: .infinity, maxHeight: 48)
//                        }
//                    }
//                    .disabled(!isReadyForPaymentCreation)
//                    .foregroundStyle(Color.white)
                }
                .listRowBackground(isReadyForPaymentCreation ? Color.blue : Color.gray)
            }
            .onAppear(perform: configureSDK)
            .onChange(of: settingsModel.isConfiguredForMakingPayment, configureSDK)
        }
    }

    var isReadyForPaymentCreation: Bool {
        return sdkState == .ready && settingsModel.isConfiguredForMakingPayment
    }
    
    func configureSDK() {
        guard settingsModel.isConfiguredForMakingPayment else { return }

        Primer.shared.delegate = delegateHandler

        Task {
            sdkState = .configuring
            settingsModel.fetchErrorMessage = nil

            do {
                try await settingsModel.setup()
                sdkState = .ready
            } catch {
                sdkState = .error
            }
        }
    }

}

class PrimerDelegateHandler: PrimerDelegate {
    func primerDidCompleteCheckoutWithData(_ data: PrimerCheckoutData) {
        print("SUCCESS")
    }
}
