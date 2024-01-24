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

class PrimerLoadingModel: ObservableObject {
    @Published var isLoading: Bool = false
}

class PrimerCardDataModel: PrimerBaseCardDataModel {
    
    var cancellables: Set<AnyCancellable> = []

    var loadingModel: PrimerLoadingModel = PrimerLoadingModel()
    
    @Published var cardNetworkModels: [CardDisplayModel] = [] {
        didSet {
            selectedCardNetwork = .unknown
            objectWillChange.send()
        }
    }
    
    var shouldDisplayCardSelectionView: Bool {
        return !cardNumber.isEmpty && !cardNetworkModels.isEmpty
    }
    
    weak var service: PrimerDataService?
    
    func selectCardNetwork(at index: Int) {
        selectedCardNetwork = cardNetworkModels[index].value
        objectWillChange.send()
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
    
    func willReceiveCardModels() {
        DispatchQueue.main.async {
            self.loadingModel.isLoading = true
        }
    }
    
    func didReceiveCardModels(models: [CardDisplayModel]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingModel.isLoading = false
            if self.cardNetworkModels.map({ $0.value.rawValue }) != models.map({ $0.value.rawValue }) {
                self.cardNetworkModels = models
            }
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
        errors.reversed().compactMap { $0 as? PrimerValidationError }.forEach { error in
            switch error {
            case .invalidCardnumber(let message, _, _):
                self.cardNumber = message
            case .invalidCardType(let message, _, _):
                self.cardNumber = message // Overrides above
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
