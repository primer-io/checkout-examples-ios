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

    let service: PrimerDataService

    init(service: PrimerDataService) {
        self.service = service
        super.init()
        objectWillChange.sink {
            DispatchQueue.main.async {
                self.service.update(withModel: self)
            }
        }.store(in: &cancellables)
        service.modelsDelegate = self
    }
    
    func makePayment(_ completion: @escaping (PaymentResultModel) -> Void) {
        service.makePayment { result in
            completion(result)
        }
    }

    func updateCardNetworks(with networks: [CardDisplayModel]) {
        cardNetworksModel.cardNetworks = networks
        if !networks.isEmpty {
            selectCardNetwork(at: 0)
        }
    }

    func selectCardNetwork(at index: Int) {
        selectedCardNetwork = cardNetworksModel.cardNetworks[index].value
        objectWillChange.send()
    }

    var isEmpty: Bool {
        [cardNumber, expiryDate, cvvNumber, cardholderName].allSatisfy { $0.isEmpty }
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
