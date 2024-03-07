//
//  PrimerDataService.swift
//  Drop-in Checkout Example
//
//  Created by Jack Newcombe on 01/11/2023.
//

import Foundation
import UIKit
import PrimerSDK

@objc
class PrimerDataService: NSObject {

    struct ClientTokenModel: Decodable {
        let clientToken: String
    }
    
    enum Error: Swift.Error {
        case failedToFetchClientToken(error: Swift.Error)
        case failedToInitialiseSDK(error: Swift.Error)
        case paymentFailed(error: Swift.Error)

        var message: String {
            switch self {
            case .failedToInitialiseSDK(let error),
                    .failedToFetchClientToken(let error),
                    .paymentFailed(let error):
                return error.localizedDescription
            }
        }
    }
    
    var clientToken: String

    init(clientToken: String) {
        self.clientToken = clientToken
    }
    
    // MARK: SDK Configuration
    
    func fetchClientToken(from url: String) async throws -> String {
        do {
            var request = URLRequest(url: URL(string: "\(url)/client-session")!)
            request.httpMethod = "POST"

            let (data, _) = try await URLSession.shared.data(for: request)
            let clientTokenModel = try JSONDecoder().decode(ClientTokenModel.self, from: data)
            self.clientToken = clientTokenModel.clientToken
            return clientToken
        } catch {
            throw Error.failedToFetchClientToken(error: error)
        }
    }
    
    // MARK: Making a payment

    typealias PaymentCompletion = (PaymentResultModel) -> Void
    
    var paymentCompletion: PaymentCompletion?
    
    private func logError(_ err: Swift.Error?) {
        logger.error(err?.localizedDescription ?? "unknown")
    }
}
