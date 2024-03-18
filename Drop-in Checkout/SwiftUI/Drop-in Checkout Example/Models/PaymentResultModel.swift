//
//  PaymentModel.swift
//  Drop-in Checkout Example
//
//  Created by Jack Newcombe on 05/12/2023.
//

import Foundation

struct PaymentResultModel: Hashable {
    let didSucceed: Bool
    let fields: [String: String]
}
