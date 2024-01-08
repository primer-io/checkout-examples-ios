//
//  PrimerCardDataModel.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 25/10/2023.
//

import Foundation
import SwiftUI
import Combine

import PrimerSDK

class PrimerBaseCardDataModel: ObservableObject {
    @Published var cardNumber: String = ""
    
    @Published var cvvNumber: String = ""
    
    @Published var expiryDate: String = ""
    
    @Published var cardholderName: String = ""
    
    @Published var selectedCardNetwork: CardNetwork = .unknown
    
    var isCardNumberFormatted: Bool {
        return (try? /(?:\d{4}+\s)*(?:\d{0,4})?/.wholeMatch(in: cardNumber)) != nil
    }
}

class PrimerCardDataModel: PrimerBaseCardDataModel {
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var cardNetworkModels: [CardDisplayModel] = [] {
        didSet {
            objectWillChange.send()
        }
    }
    
    var shouldDisplayCardSelectionView: Bool {
        return !cardNumber.isEmpty && !cardNetworkModels.isEmpty
    }
    
    weak var service: PrimerDataService?
    
    func selectCardNetwork(at index: Int) {
        selectedCardNetwork = cardNetworkModels[index].value
    }
    
    override init() {
        super.init()
        logger.info("[PrimerCardDataModel.init]")
        objectWillChange.sink {
            self.service?.update(withModel: self)
        }.store(in: &cancellables)
    }
}

extension PrimerCardDataModel: PrimerDataServiceModelsDelegate {
    func didCompletePayment(payment: PaymentResultModel) {
        
    }
    
    func didReceiveCardModels(models: [CardDisplayModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.cardNetworkModels = models
        }
    }
}

// MARK: Errors Model

class PrimerCardDataErrorsModel: PrimerBaseCardDataModel {
    
    fileprivate func clearErrors() {
        self.cardNumber = ""
        self.expiryDate = ""
        self.cvvNumber = ""
        self.cardholderName = ""
        self.selectedCardNetwork = .unknown
    }
}

extension PrimerCardDataErrorsModel: PrimerDataServiceErrorsDelegate {
    func didReceiveErrors(errors: [Error]) {
        self.clearErrors()
        errors.compactMap { $0 as? PrimerValidationError }.forEach { error in
            switch error {
            case .invalidCardnumber(let message, _, _):
                self.cardNumber = message
            case .invalidExpiryDate(let message, _, _):
                self.expiryDate = message
            case .invalidCvv(let message, _, _):
                self.cvvNumber = message
            case .invalidCardholderName(let message, _, _):
                self.cardholderName = message
            default: break
            }
        }
    }
}
