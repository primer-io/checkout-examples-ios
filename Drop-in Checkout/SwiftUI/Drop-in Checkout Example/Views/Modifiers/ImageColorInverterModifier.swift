//
//  ImageColorInverterModifier.swift
//  Drop-in Checkout Example
//
//  Created by Jack Newcombe on 03/11/2023.
//

import SwiftUI

struct ImageColorInverterModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .light {
            content
        } else {
            content.colorInvert()
        }
    }
}

extension View {
    func themedColorInvert() -> some View {
        return modifier(ImageColorInverterModifier())
    }
}
