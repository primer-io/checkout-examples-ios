//
//  PrimerCardDataErrorsModel.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 26/01/2024.
//

import Foundation
import PrimerSDK

class PrimerCardDataErrorsModel: PrimerBaseCardDataModel {
    
    init(service: PrimerDataService) {
        super.init()
        logger.info("[PrimerCardDataErrorsModel.init]")
        service.errorsDelegate = self
    }
    
    fileprivate func clearErrors() {
        self.cardNumber = ""
        self.expiryDate = ""
        self.cvvNumber = ""
        self.cardholderName = ""
        self.selectedCardNetwork = .unknown
    }
    
    var hasErrors: Bool {
        !(
            cardNumber.isEmpty &&
            expiryDate.isEmpty &&
            cvvNumber.isEmpty &&
            cardholderName.isEmpty
        )
    }
}

extension PrimerCardDataErrorsModel: PrimerDataServiceErrorsDelegate {
    func didReceiveErrors(errors: [Error]) {
        logger.info("[PrimerCardDataModel.didReceiveErrors]")
        DispatchQueue.main.async {
            self.clearErrors()
            
            let validationErrors = errors.reversed().compactMap { $0 as? PrimerValidationError }
            
            validationErrors.forEach { error in
                logger.info("[PrimerCardDataModel.didReceiveErrors] error => \(error.errorId)")
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
}
