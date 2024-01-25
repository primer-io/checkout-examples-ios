//
//  ContentView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 24/10/2023.
//

import SwiftUI
import Combine

struct CardFormFullPageView: View {
    
    let service: PrimerDataService

    var model: PrimerCardDataModel = .init()
    
    @StateObject var errorsModel: PrimerCardDataErrorsModel = .init()
    
    var cancellables: Set<AnyCancellable> = []
    
    @State var paymentModel: PaymentResultModel?
    
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
        self.model.service = service
        self.service.errorsDelegate = errorsModel
        self.service.modelsDelegate = model
    }
    
    func onSubmit(_ completion: @escaping () -> Void) {
        service.makePayment { result in
            self.paymentModel = result
            completion()
        }
    }
    
}

#Preview {
    CardFormFullPageView(service: .init(clientToken: ""),
                         model: .init(),
                         errorsModel: .init())
}
