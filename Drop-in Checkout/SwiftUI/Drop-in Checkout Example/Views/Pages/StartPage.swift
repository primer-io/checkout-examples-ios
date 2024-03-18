//
//  StartPage.swift
//  Drop-in Checkout Example
//
//  Created by Jack Newcombe on 13/11/2023.
//

import SwiftUI
import PrimerSDK

enum SDKState {
    case inactive
    case configuring
    case ready
    case error
}

struct StartPage: View {

    @StateObject var settingsModel: SettingsModel

    @State var sdkState: SDKState = .inactive

    @State var delegateHandler: PrimerDelegateHandler?

    @State var paymentResultModel: PaymentResultModel?

    var body: some View {
        VStack {
            Form {
                FormInfo {
                    Text(LocalizedStringKey("Start.Text.Title")).font(.title)
                    Text(LocalizedStringKey("Start.Text.About")).font(.body).fontWeight(.light)
                }

                SettingsView(settingsModel: settingsModel)

                Section {
                    PrimerButton(action: didTapShowCheckout,
                                 labelText: "Show checkout",
                                 isEnabled: isReadyForPaymentCreation)
                }
                .listRowBackground(isReadyForPaymentCreation ? Color.blue : Color.gray)
            }
            .onAppear(perform: configureSDK)
            .onChange(of: settingsModel.isConfiguredForMakingPayment, configureSDK)
            .navigationDestination(item: $paymentResultModel) { model in
                PaymentResultPage(model: model)
            }
        }
    }

    var isReadyForPaymentCreation: Bool {
        return sdkState == .ready && settingsModel.isConfiguredForMakingPayment
    }

    func configureSDK() {
        guard settingsModel.isConfiguredForMakingPayment else { return }

        delegateHandler = PrimerDelegateHandler(receiver: self)
        Primer.shared.delegate = delegateHandler

        Task {
            sdkState = .configuring
            settingsModel.fetchErrorMessage = nil

            do {
                try await settingsModel.setup()
                sdkState = .ready
            } catch {
                sdkState = .error
            }
        }
    }

    func didTapShowCheckout(completion: @escaping () -> Void) {
        Primer.shared.showUniversalCheckout(clientToken: settingsModel.clientToken,
                                            completion: { _ in completion() })
    }
}

extension StartPage: PaymentResultReceiver {
    func onPaymentSuccess(orderId: String?, paymentId: String?) {
        paymentResultModel = PaymentResultModel(didSucceed: true, fields: [
            "Order ID" : orderId ?? "Unknown",
            "Payment ID": paymentId ?? "Unknown"
        ])
    }

    func onPaymentFailure(reason: String) {
        paymentResultModel = PaymentResultModel(didSucceed: false, fields: [
            "Reason": reason
        ])
    }
}

class PrimerDelegateHandler: PrimerDelegate {

    let receiver: PaymentResultReceiver

    init(receiver: PaymentResultReceiver) {
        self.receiver = receiver
    }

    func primerDidCompleteCheckoutWithData(_ data: PrimerCheckoutData) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Primer.shared.dismiss()
            self.receiver.onPaymentSuccess(orderId: data.payment?.orderId,
                                           paymentId: data.payment?.id)
        }
    }

    func primerDidFailWithError(_ error: Error, data: PrimerCheckoutData?, decisionHandler: @escaping ((PrimerErrorDecision) -> Void)) {
        decisionHandler(.fail(withErrorMessage: "You can configure this error message to be whatever you like"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            Primer.shared.dismiss()
            self.receiver.onPaymentFailure(reason: error.localizedDescription)
        }
    }
}


protocol PaymentResultReceiver {
    func onPaymentSuccess(orderId: String?, paymentId: String?)
    func onPaymentFailure(reason: String)
}
