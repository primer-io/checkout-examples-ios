//
//  SettingsView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 10/11/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var settingsModel: SettingsModel
    
    @State var isFetchingClientToken: Bool = false

    var body: some View {
        Group {
            Section {
                TextField(LocalizedStringKey("Settings.ClientToken.Placeholder"),
                          text: $settingsModel.clientToken,
                          axis: .vertical)
                    .font(.monospaced)
            } header: {
                Text(LocalizedStringKey("Settings.ClientToken.Title"))
            } footer: {
                Divider()
                    .padding(.bottom, 0)
                    .padding(.top, 12)
            }
            
            Section {
                TextField(
                    "",
                    text: $settingsModel.clientTokenUrl,
                    prompt: Text(verbatim: "https://my.glitch.server")
                )
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                Button {
                    onFetchClientToken()
                } label: {
                    if isFetchingClientToken {
                        ProgressView()
                    }
                    else if !settingsModel.isClientTokenValid {
                        Text("Settings.Button.FetchClientToken")
                    }
                    else {
                        Text(LocalizedStringKey("Settings.Button.RefetchClientToken"))
                    }
                }
                .foregroundStyle(.blue)
                .disabled(settingsModel.clientTokenUrl.isEmpty)
            }
            
            if let fetchErrorMessage = settingsModel.fetchErrorMessage {
                FormInfo {
                    Text(fetchErrorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .onAppear(perform: onAppear)
    }

    private func onAppear() {
        if let _ = URL(string: settingsModel.clientTokenUrl) {
            onFetchClientToken()
        }
    }

    private func onFetchClientToken() {
        Task {
            isFetchingClientToken = true
            defer { isFetchingClientToken = false }

            try await settingsModel.updateClientToken()
        }
    }
    
    var toolbar: some View {
        Button(LocalizedStringKey("Dismiss")) {
            settingsModel.isPresented = false
        }.foregroundColor(.white)
    }
}

#Preview {
    Form {
        SettingsView(settingsModel: .init(service: .init(clientToken: "")))
    }
}
