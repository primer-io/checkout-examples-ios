//
//  PrimerButton.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 10/11/2023.
//

import SwiftUI

struct PrimerButton: View {
    
    let action: (_ completion: @escaping () -> Void) -> Void
    
    let labelText: String
    
    @State var isWaitingForActionToComplete: Bool = false
    
    var body: some View {
        Button {
            isWaitingForActionToComplete = true
            action {
                isWaitingForActionToComplete = false
            }
        } label: {
            if isWaitingForActionToComplete {
                ButtonProgressView()
                    .frame(maxHeight: 48)
            } else {
                Text(labelText)
                    .frame(maxWidth: .infinity, maxHeight: 48)
            }
        }
        .primerButtonStyle()
        .disabled(isWaitingForActionToComplete)
    }
}
