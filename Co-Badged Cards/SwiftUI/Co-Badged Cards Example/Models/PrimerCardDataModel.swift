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

class PrimerCardNetworksModel: ObservableObject {
    var cardNetworks: [CardDisplayModel] = []
}

class PrimerCardDataModel: PrimerBaseCardDataModel {
    
    var cancellables: Set<AnyCancellable> = []

    var loadingModel: PrimerLoadingModel = PrimerLoadingModel()
    
    var cardNetworksModel: PrimerCardNetworksModel = PrimerCardNetworksModel()
    
    var shouldDisplayCardSelectionView: Bool {
        return !cardNumber.isEmpty && !cardNetworksModel.cardNetworks.isEmpty
    }
    
    weak var service: PrimerDataService?
    
    func updateCardNetworks(with networks: [CardDisplayModel]) {
        cardNetworksModel.cardNetworks = networks
        selectedCardNetwork = .unknown
    }
    
    func selectCardNetwork(at index: Int) {
        selectedCardNetwork = cardNetworksModel.cardNetworks[index].value
        objectWillChange.send()
    }
    
    override init() {
        super.init()
        logger.info("[PrimerCardDataModel.init]")
        objectWillChange.sink {
            DispatchQueue.main.async {
                self.service?.update(withModel: self)
            }
        }.store(in: &cancellables)
    }
    
    var isEmpty: Bool {
        cardNumber.isEmpty &&
        expiryDate.isEmpty &&
        cvvNumber.isEmpty &&
        cardholderName.isEmpty
    }
}

extension PrimerCardDataModel: PrimerDataServiceModelsDelegate {
    
    func willReceiveCardModels() {
        logger.info("[PrimerCardDataModel.willReceiveCardModels]")
        DispatchQueue.main.async {
            self.loadingModel.isLoading = true
        }
    }
    
    func didReceiveCardModels(models: [CardDisplayModel]) {
        logger.info("[PrimerCardDataModel.didReceiveCardModels] => \(models.map { $0.value.rawValue })")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingModel.isLoading = false
            if self.cardNetworksModel.cardNetworks.map({ $0.value.rawValue }) != models.map({ $0.value.rawValue }) {
                self.cardNetworksModel.cardNetworks = models
            }
        }
    }
}
