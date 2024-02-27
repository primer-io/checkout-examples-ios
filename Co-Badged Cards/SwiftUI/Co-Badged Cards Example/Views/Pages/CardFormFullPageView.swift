//
//  ContentView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 24/10/2023.
//

import SwiftUI
import Combine

struct CardFormFullPageView: View {
    
    let model: PrimerCardDataModel

    @StateObject var errorsModel: PrimerCardDataErrorsModel
    
    var cancellables: Set<AnyCancellable> = []
    
    @State var paymentModel: PaymentResultModel?

    init(model: PrimerCardDataModel, errorsModel: PrimerCardDataErrorsModel) {
        self.model = model
        self._errorsModel = StateObject(wrappedValue: errorsModel)
    }

    var body: some View {
        VStack(spacing: 12) {
            Image("primer-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .themedColorInvert()
            CardDetailsFormView(model: model, errors: errorsModel, onSubmit: onSubmit)
                .onAppear(perform: onAppear)
        }
        .navigationDestination(item: $paymentModel) { model in
            PaymentResultPage(model: model)
        }
    }
    
    func onAppear() {
    }
    
    func onSubmit(_ completion: @escaping () -> Void) {
        model.makePayment { result in
            self.paymentModel = result
            completion()
        }
    }
    
}

#Preview {
    CardFormFullPageView(model: .init(service: .init(clientToken: "")),
                         errorsModel: .init(service: .init(clientToken: "")))
}
