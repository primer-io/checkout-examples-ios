//
//  ButtonProgressView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 06/12/2023.
//

import SwiftUI

struct ButtonProgressView: View {
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
            Spacer()
        }
    }
}

#Preview {
    ButtonProgressView()
}
