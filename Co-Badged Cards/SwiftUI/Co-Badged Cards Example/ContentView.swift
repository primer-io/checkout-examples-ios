//
//  ContentView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 09/11/2023.
//

import SwiftUI

struct ContentView: View {
    
    let service: PrimerDataService
    
    @StateObject var settingsModel: SettingsModel = .init()
            
    var body: some View {
        StartPage(service: service, settingsModel: settingsModel)
            .navigationTitle("App.Title")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(settingsModel.$clientToken, perform: onReceive(clientToken:))
    }
    
    func onReceive(clientToken: String) {
        service.clientToken = clientToken
    }
}
