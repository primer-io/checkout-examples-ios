//
//  SettingsView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 10/11/2023.
//

import SwiftUI

struct SettingsView: View {
    
    let service: PrimerDataService
    
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
                TextField(LocalizedStringKey("Settings.ClientTokenUrl.Placeholder"), text: $settingsModel.clientTokenUrl)
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
    }
    
    private func onFetchClientToken() {
        Task {
            settingsModel.fetchErrorMessage = nil
            isFetchingClientToken = true

            defer {
                isFetchingClientToken = false
            }

            do {
                settingsModel.clientToken = try await service.fetchClientToken(from: settingsModel.clientTokenUrl)
            } catch {
                settingsModel.fetchErrorMessage = """
Could not fetch a client token from:
POST \(settingsModel.clientTokenUrl)
Make sure the server is running and that your network connection is working.
"""
                settingsModel.clientToken = ""
                throw error
            }
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
        SettingsView(service: .init(clientToken: ""), settingsModel: .init())
    }
}
