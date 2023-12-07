//
//  PaymentResultPage.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 05/12/2023.
//

import SwiftUI

struct PaymentResultPage: View {
    
    let model: PaymentResultModel
    
    var body: some View {
        Form {
            heading
            
            ForEach(Array(model.fields.keys), id: \.self) { key in
                Section {
                    Text(model.fields[key] ?? "Unknown")
                        .font(.monospaced)
                } header: {
                    Text(key)
                }
            }
        }
    }
    
    var heading: some View {
        FormInfo {
            HStack {
                Text(paymentOutcomeTitle)
                    .font(.headline)
                    .textScale(.secondary)
                Spacer()
                Image(systemName: "\(model.didSucceed ? "checkmark" : "xmark").circle.fill")
            }
            .foregroundStyle(model.didSucceed ? .green : .red)
        }
    }
    
    var paymentOutcomeTitle: LocalizedStringKey {
        if model.didSucceed {
            LocalizedStringKey("PaymentResult.Result.SuccessTitle")
        } else {
            LocalizedStringKey("PaymentResult.Result.FailureTitle")
        }
    }
}

#Preview {
    PaymentResultPage(model: .init(didSucceed: true, fields: [:]))
}
