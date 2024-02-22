//
//  StartPage.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 13/11/2023.
//

import SwiftUI

enum SDKState {
    case inactive
    case configuring
    case ready
    case error
}

struct StartPage: View {
    
    @StateObject var settingsModel: SettingsModel

    @State var sdkState: SDKState = .inactive
    
    var body: some View {
        VStack {
            Form {
                FormInfo {
                    Text(LocalizedStringKey("Start.Text.Title")).font(.title)
                    Text(LocalizedStringKey("Start.Text.About")).font(.body).fontWeight(.light)
                }
                
                SettingsView(settingsModel: settingsModel)
                
                Section {
                    NavigationLink(destination: fullPageView) {
                        if sdkState == .configuring {
                            ButtonProgressView()
                        } else {
                            Text(LocalizedStringKey("Start.Button.MakePayment"))
                                .frame(maxWidth: .infinity, maxHeight: 48)
                        }
                    }
                    .disabled(!isReadyForPaymentCreation)
                    .foregroundStyle(Color.white)
                }
                .listRowBackground(isReadyForPaymentCreation ? Color.blue : Color.gray)
            }
            .onAppear(perform: configureSDK)
            .onChange(of: settingsModel.isConfiguredForMakingPayment, configureSDK)
        }
    }
    
    var fullPageView: some View {
        CardFormFullPageView(service: settingsModel.service) // JN TODO
    }
    
    var isReadyForPaymentCreation: Bool {
        return sdkState == .ready && settingsModel.isConfiguredForMakingPayment
    }
    
    func configureSDK() {
        guard settingsModel.isConfiguredForMakingPayment else { return }

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
