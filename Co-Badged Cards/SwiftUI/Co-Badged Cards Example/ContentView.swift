//
//  ContentView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 09/11/2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var settingsModel: SettingsModel

    init(service: PrimerDataService) {
        _settingsModel = StateObject(wrappedValue: SettingsModel(service:  service))
    }

    var body: some View {
        StartPage(settingsModel: settingsModel)
            .navigationTitle("App.Title")
            .navigationBarTitleDisplayMode(.inline)
    }
}
