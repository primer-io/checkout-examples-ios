//
//  SettingsModel.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 14/11/2023.
//

import SwiftUI

class SettingsModel: ObservableObject {
    
    enum Key: String {
        case apiKey = "API_KEY"
        case clientToken = "CLIENT_TOKEN"
        case clientTokenUrl = "CLIENT_TOKEN_URL"
    }
    
    let service: PrimerDataService

    @Published var clientToken: String = ""
    
    @Published var clientTokenUrl: String = "" {
        didSet {
            UserDefaults.standard.setValue(clientTokenUrl, forKey: Key.clientTokenUrl.rawValue)
        }
    }
    
    @Published var isPresented: Bool = false
    
    @Published var fetchErrorMessage: String? = nil

    init(service: PrimerDataService) {
        self.service = service
        
        if let clientToken = UserDefaults.standard.string(forKey: Key.clientToken.rawValue) {
            self.clientToken = clientToken
        } else if !ExampleApp.clientToken.isEmpty {
            self.clientToken = ExampleApp.clientToken
        }
        if let clientTokenUrl = UserDefaults.standard.string(forKey: Key.clientTokenUrl.rawValue) {
            self.clientTokenUrl = clientTokenUrl
        } else {
            self.clientTokenUrl = ExampleApp.clientTokenUrl
        }
    }
    
    var isClientTokenValid: Bool {
        return !clientToken.isEmpty && isValidJWT(clientToken)
    }

    func updateClientToken() async throws {
        DispatchQueue.main.sync {
            fetchErrorMessage = nil
        }
        do {
            let clientToken = try await service.fetchClientToken(from: clientTokenUrl)
            DispatchQueue.main.sync {
                self.clientToken = clientToken
            }
        } catch {
            DispatchQueue.main.sync {
                fetchErrorMessage = """
Could not fetch a client token from:
POST \(clientTokenUrl)
Make sure the server is running and that your network connection is working.
"""
                clientToken = ""
            }
            throw error
        }
    }

    func setup() async throws {
        if !isClientTokenValid {
            try await updateClientToken()
        }

        do {
            try await service.start()
            service.configureForPayments()
        } catch {
            logger.error(error.localizedDescription)
            fetchErrorMessage = """
There was an error starting the SDK - check your configuration.
"""
            clientToken = ""

            switch (error as? PrimerDataService.Error) {
            case .failedToFetchClientToken(let error),
                    .failedToInitialiseSDK(let error):
                logger.error(error.localizedDescription)
            default: break
            }

            throw error
        }
    }

    // MARK: Helpers
    
    var isConfiguredForMakingPayment: Bool {
        return isClientTokenValid
    }
    
    private func isValidJWT(_ token: String) -> Bool {
        let components = token.components(separatedBy: ".")
        
        guard components.count == 3 else {
            return false
        }
        
        return components.allSatisfy { (try? /[\w\d=\+\-\/]+/.wholeMatch(in: $0)) != nil }
    }
}
