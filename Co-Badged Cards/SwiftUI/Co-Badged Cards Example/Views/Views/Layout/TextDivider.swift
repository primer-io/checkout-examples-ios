//
//  TextDivider.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 24/11/2023.
//

import SwiftUI

struct TextDivider: View {
    
    let title: Text
    
    let foregroundColor: Color
    
    let thickness: CGFloat
    
    init(_ title: LocalizedStringKey = LocalizedStringKey("or"),
         foregroundColor: Color = .black,
         thickness: CGFloat = 2) {
        self.init(title: Text(title),
                  foregroundColor: foregroundColor,
                  thickness: thickness)
    }
    
    init<S>(_ title: S = "or",
            foregroundColor: Color = .black,
            thickness: CGFloat = 2) where S: StringProtocol {
        self.init(title: Text(title),
                  foregroundColor: foregroundColor,
                  thickness: thickness)
    }
    
    private init(title: Text,
                 foregroundColor: Color,
                 thickness: CGFloat) {
        self.title = title
        self.foregroundColor = foregroundColor
        self.thickness = thickness
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(foregroundColor)
                .frame(height: thickness)
            title
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(foregroundColor)
            Rectangle()
                .fill(foregroundColor)
                .frame(height: thickness)
        }
        .padding([.top, .bottom], 1)
    }
}

#Preview {
    TextDivider("Test")
}
