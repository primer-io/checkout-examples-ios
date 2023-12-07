//
//  PrimerDataService.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 01/11/2023.
//

import Foundation
import PrimerSDK

typealias RawDataManager = PrimerHeadlessUniversalCheckout.RawDataManager
typealias PaymentMethod = PrimerHeadlessUniversalCheckout.PaymentMethod

private let cardPaymentMethodName = "PAYMENT_CARD"

protocol PrimerDataServiceErrorsDelegate {
    func didReceiveErrors(errors: [Error])
}

protocol PrimerDataServiceModelsDelegate {
    func didReceiveCardModels(models: [CardDisplayModel])
    func didCompletePayment(payment: PaymentResultModel)
}

@objc
class PrimerDataService: NSObject {
    
    typealias ErrorsDelegate = PrimerDataServiceErrorsDelegate
    typealias ModelsDelegate = PrimerDataServiceModelsDelegate
    
    struct ClientTokenRequestModel: Encodable {
        let currencyCode: String
        let amount: Int
    }
    
    struct ClientTokenModel: Decodable {
        let clientToken: String
    }
    
    enum Error: Swift.Error {
        case failedToFetchClientToken(error: Swift.Error)
        case failedToInitialiseSDK(error: Swift.Error)
        case paymentFailed(error: Swift.Error)
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
    
    func fetchClientToken(from url: String) async throws -> String {
        do {
            var request = URLRequest(url: URL(string: "\(url)/client-session")!)
            request.httpBody = try JSONEncoder().encode(ClientTokenRequestModel(currencyCode: "GBP", amount: 4999))
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func configureForPayments() async {
        await withCheckedContinuation { continuation in
            guard let cardPaymentMethod = paymentMethods?.first(where: { $0.paymentMethodType == cardPaymentMethodName }) else {
                logger.error("Failed to find card payment method")
                continuation.resume()
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
            continuation.resume()
        }
    }
    
    func update(withModel model: PrimerCardDataModel) {
        rawDataManager?.rawData = PrimerCardData(
            cardNumber: model.cardNumber,
            expiryDate: model.expiryDate,
            cvv: model.cvvNumber,
            cardholderName: model.cardholderName,
            cardNetworkIdentifier: model.selectedCardNetwork.isEmpty ? nil : model.selectedCardNetwork // JN TODO: move logic to SDK? Pretty sure
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
                              willFetchCardMetadataForState cardState: PrimerCardNumberEntryState) {
        logger.info("willFetchCardMetadataForState: \(cardState.cardNumber)")
        currentModels = nil
    }
    
    func primerRawDataManager(_ rawDataManager: PrimerHeadlessUniversalCheckout.RawDataManager,
                              didReceiveCardMetadata metadata: PrimerCardNumberEntryMetadata,
                              forCardState cardState: PrimerCardNumberEntryState) {
        let metadataDescription = metadata.availableCardNetworks.map { $0.displayName }.joined(separator: ", ")
        logger.info("didReceiveCardMetadata: \(metadataDescription), cardState: \(cardState.cardNumber)")
        
        currentModels = metadata.availableCardNetworks
        let models = metadata.availableCardNetworks
            .filter { $0.displayName != "Unknown" }
            .enumerated()
            .map { index, model in
                // JN TODO: should be getting image from the asset manager
                CardDisplayModel(index: index, name: model.displayName, image: mapImageName(model))
            }
        modelsDelegate?.didReceiveCardModels(models: models)
    }
    
    // JN TODO: should be getting this from the asset manager
    private func mapImageName(_ model: PrimerCardNetwork) -> String {
        if model.displayName == "Mastercard" {
            return "MasterCard"
        }
        return model.displayName
    }
}
