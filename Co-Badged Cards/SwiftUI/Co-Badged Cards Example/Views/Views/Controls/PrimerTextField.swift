//
//  PrimerTextField.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 24/10/2023.
//

import SwiftUI

struct PrimerTextField: View {
    
    let title: String
    
    let placeholder: String
    
    let formatter: Formatter?

    var text: Binding<String>
    
    var errorMessage: Binding<String>
    
    init(title: String, 
         placeholder: String,
         formatter: Formatter? = nil,
         text: Binding<String>,
         errorMessage: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        self.formatter = formatter
        self.text = text
        self.errorMessage = errorMessage
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.blue)
            TextField(placeholder, value: text, formatter: formatter ?? EmptyFormatter())
                .textFieldStyle(.plain)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.blue)
            if !text.wrappedValue.isEmpty, !errorMessage.wrappedValue.isEmpty {
                Text(errorMessage.wrappedValue)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(8)
    }
}

#Preview {
    VStack(spacing: 0) {
        PrimerTextField(
            title: "Card number",
            placeholder: "5522 1001 0000 0001",
            text: .constant(""),
            errorMessage: .constant("")
        )
        HStack(alignment: .top, spacing: 0) {
            PrimerTextField(
                title: "Expiry Date",
                placeholder: "12/24",
                text: .constant(""),
                errorMessage: .constant("")
            )
            .padding(.trailing, 0)
            PrimerTextField(
                title: "CVV",
                placeholder: "123",
                text: .constant(""),
                errorMessage: .constant("")
            )
            .padding(.leading, 0)
        }
        PrimerTextField(
            title: "Name",
            placeholder: "e.g. John Appleseed",
            text: .constant(""),
            errorMessage: .constant("")
        )
    }
}
