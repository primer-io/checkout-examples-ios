//
//  StatusBarShim.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 14/11/2023.
//

import SwiftUI

struct StatusBarShim: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(.black)
                .frame(maxWidth: .infinity, maxHeight: 54)
                .ignoresSafeArea()
            Spacer()
        }
    }
}

#Preview {
    StatusBarShim()
}
