//
//  CardDetailsFormView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 24/10/2023.
//

import SwiftUI

struct CardDetailsFormView: View {
    
    @StateObject var model: PrimerCardDataModel
    
    @StateObject var errors: PrimerCardDataErrorsModel
    
    let onSubmit: (_ completion: @escaping () -> Void) -> Void
    
    @State var isMakingPayment: Bool = false
    
    @State var selectedCardNetworkIndex: Int? = nil {
        didSet {
            if let index = selectedCardNetworkIndex {
                model.selectCardNetwork(at: index)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 4) {
                PrimerTextField(
                    title: "Card number",
                    placeholder: "5522 1001 0000 0001",
                    formatter: CardNumberFormatter(),
                    text: $model.cardNumber,
                    errorMessage: $errors.cardNumber
                )
//                if model.shouldDisplayCardSelectionView {
                    CardSelectionView(cards: $model.cardNetworkModels) { index in
                        selectedCardNetworkIndex = index
                    }
                    .frame(height: 45)
                    // Align with text field - account for border (1)
                    .padding(.bottom, errors.cardNumber.isEmpty ? 1 : 19)
                    .padding(.trailing, 8)
//                }
            }
            HStack(spacing: 0) {
                PrimerTextField(
                    title: "Expiry Date",
                    placeholder: "06/2025",
                    text: $model.expiryDate,
                    errorMessage: $errors.expiryDate
                )
                .padding(.trailing, 0)
                PrimerTextField(
                    title: "CVV",
                    placeholder: "123",
                    text: $model.cvvNumber,
                    errorMessage: $errors.cvvNumber
                )
                .padding(.leading, 0)
            }
            PrimerTextField(
                title: "Name",
                placeholder: "e.g. John Appleseed",
                text: $model.cardholderName,
                errorMessage: $errors.cardholderName
            )
            
            VStack(spacing: 12) {
                AllowedNetworksView()
                PrimerButton(action: onSubmit, labelText: "Pay")
            }
            .padding([.leading, .trailing], 6)
        }
    }
}

#Preview {
    CardDetailsFormView(model: .init(), errors: .init()) { _ in }
}
