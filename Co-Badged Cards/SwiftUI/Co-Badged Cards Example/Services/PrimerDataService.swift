//
//  PrimerDataService.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 01/11/2023.
//

import Foundation
import UIKit
import PrimerSDK

typealias RawDataManager = PrimerHeadlessUniversalCheckout.RawDataManager
typealias PaymentMethod = PrimerHeadlessUniversalCheckout.PaymentMethod

private let cardPaymentMethodName = "PAYMENT_CARD"

protocol PrimerDataServiceErrorsDelegate {
    func didReceiveErrors(errors: [Error])
}

protocol PrimerDataServiceModelsDelegate {
    func willReceiveCardModels()
    func didReceiveCardModels(models: [CardDisplayModel])
}

@objc
class PrimerDataService: NSObject {
    
    typealias ErrorsDelegate = PrimerDataServiceErrorsDelegate
    typealias ModelsDelegate = PrimerDataServiceModelsDelegate
    
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
    
    private var rawDataManager: RawDataManager?
    
    private var paymentMethods: [PaymentMethod]?
    
    fileprivate var currentModels: [PrimerCardNetwork]?

    var errorsDelegate: ErrorsDelegate?
    var modelsDelegate: ModelsDelegate?
    
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
    
    func start() async throws {
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Swift.Error>) in
            PrimerHeadlessUniversalCheckout.current.start(withClientToken: clientToken) { paymentMethods, err in
                guard err == nil else {
                    self.logError(err)
                    continuation.resume(with: .failure(Self.Error.failedToInitialiseSDK(error: err!)))
                    return
                }
                self.paymentMethods = paymentMethods
                continuation.resume()
            }
        }
    }
    
    func configureForPayments() {
        guard let cardPaymentMethod = paymentMethods?.first(where: { $0.paymentMethodType == cardPaymentMethodName }) else {
            logger.error("Failed to find card payment method")
            return
        }

        do {
            rawDataManager = try RawDataManager(paymentMethodType: cardPaymentMethod.paymentMethodType)
            rawDataManager?.delegate = self
            logger.info("Successfully set up RawDataManager ✔")
        }
        catch {
            logError(error)
        }
    }
    
    func update(withModel model: PrimerCardDataModel) {
        let network = model.selectedCardNetwork == .unknown ? nil : model.selectedCardNetwork
                    
        rawDataManager?.rawData = PrimerCardData(
            cardNumber: model.cardNumber,
            expiryDate: model.expiryDate,
            cvv: model.cvvNumber,
            cardholderName: model.cardholderName,
            cardNetwork: network
        )
    }
    
    // MARK: Making a payment
    
    typealias PaymentCompletion = (PaymentResultModel) -> Void
    
    var paymentCompletion: PaymentCompletion?
    
    func makePayment(_ completion: @escaping PaymentCompletion) {
        self.paymentCompletion = completion
        PrimerHeadlessUniversalCheckout.current.delegate = self
        rawDataManager?.submit()
    }
    
    private func logError(_ err: Swift.Error?) {
        logger.error(err?.localizedDescription ?? "unknown")
    }
}

extension PrimerDataService: PrimerHeadlessUniversalCheckoutDelegate {
    func primerHeadlessUniversalCheckoutDidCompleteCheckoutWithData(_ data: PrimerCheckoutData) {
        guard data.payment?.paymentFailureReason == nil else {
            logger.error("Payment failed but no failure reason was provided")
            return
        }
        let orderId = data.payment?.orderId
        let paymentId = data.payment?.id

        let model = PaymentResultModel(didSucceed: true, fields: [
            "Order ID" : orderId ?? "Unknown",
            "Payment ID": paymentId ?? "Unknown"
        ])

        paymentCompletion?(model)
        paymentCompletion = nil
    }
    
    func primerHeadlessUniversalCheckoutDidFail(withError err: Swift.Error, checkoutData: PrimerCheckoutData?) {
        paymentCompletion?(PaymentResultModel(didSucceed: false, fields: ["Error": err.localizedDescription]))
        paymentCompletion = nil
    }
}

extension PrimerDataService: PrimerHeadlessUniversalCheckoutRawDataManagerDelegate {
    
    func primerRawDataManager(_ rawDataManager: PrimerHeadlessUniversalCheckout.RawDataManager,
                              dataIsValid isValid: Bool,
                              errors: [Swift.Error]?) {
        let errorsDescription = errors?.map { $0.localizedDescription }.joined(separator: ", ")
        logger.info("dataIsValid: \(isValid), errors: \(errorsDescription ?? "none")")
        if !isValid, let errors = errors {
            errorsDelegate?.didReceiveErrors(errors: errors)
        } else {
            errorsDelegate?.didReceiveErrors(errors: [])
        }
    }
    
    func primerRawDataManager(_ rawDataManager: PrimerHeadlessUniversalCheckout.RawDataManager, 
                              metadataDidChange metadata: [String : Any]?) {
        logger.info("metadataDidChange: \(metadata ?? [:])")
    }
    
    func primerRawDataManager(_ rawDataManager: PrimerHeadlessUniversalCheckout.RawDataManager,
                              willFetchMetadataForState cardState: PrimerValidationState) {
        guard let state = cardState as? PrimerCardNumberEntryState else {
            logger.error("Received non-card metadata. Ignoring ...")
            return
        }
        logger.info("willFetchCardMetadataForState: \(state.cardNumber)")
        modelsDelegate?.willReceiveCardModels()
        currentModels = nil
    }
    
    
    func primerRawDataManager(_ rawDataManager: PrimerHeadlessUniversalCheckout.RawDataManager,
                              didReceiveMetadata metadata: PrimerPaymentMethodMetadata,
                              forState cardState: PrimerValidationState) {
        
        guard let metadata = metadata as? PrimerCardNumberEntryMetadata,
              let cardState = cardState as? PrimerCardNumberEntryState else {
            logger.error("Received non-card metadata. Ignoring ...")
            return
        }
        
        let metadataDescription = metadata.selectableCardNetworks?.items.map { $0.displayName }.joined(separator: ", ") ?? "n/a"
        logger.info("didReceiveCardMetadata: (selectable ->) \(metadataDescription), cardState: \(cardState.cardNumber)")
        
        var isAllowed = true
        
        if metadata.source == .remote, let networks = metadata.selectableCardNetworks?.items, !networks.isEmpty {
            currentModels = metadata.selectableCardNetworks?.items
        } else if let preferredDetectedNetwork = metadata.detectedCardNetworks.preferred {
            currentModels = [preferredDetectedNetwork]
        } else if let cardNetwork = metadata.detectedCardNetworks.items.first {
            currentModels = [cardNetwork]
            isAllowed = false
        } else {
            currentModels = []
        }

        let models = currentModels?
            .filter { $0.displayName != "Unknown" }
            .enumerated()
            .map { index, model in
                CardDisplayModel(index: index,
                                 name: model.displayName,
                                 image: image(from: model), 
                                 isAllowed: isAllowed,
                                 value: model.network)
            }
        
        modelsDelegate?.didReceiveCardModels(models: models ?? [])
    }
    
    private func image(from model: PrimerCardNetwork) -> UIImage? {
        let asset = PrimerHeadlessUniversalCheckout.AssetsManager.getCardNetworkAsset(for: model.network)
        return asset?.cardImage
    }
}
