//
//  CustomButtonStyle.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 02/11/2023.
//

import Foundation
import SwiftUI

private func applyButtonStyle<Content>(_ content: Content, 
                                       isPressed: Bool,
                                       isEnabled: Bool) -> some View where Content: View  {
    content
        .foregroundStyle(.white)
        .background(isEnabled ? .blue : .gray)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .opacity(isPressed ? 0.95 : 1.0)
        .animation(.easeOut(duration: 0.1), value: isPressed)
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProxyView(configuration: configuration)
    }
    
    struct ProxyView: View {
        @Environment(\.isEnabled) private var isEnabled: Bool
        
        let configuration: CustomButtonStyle.Configuration
        
        init(configuration: CustomButtonStyle.Configuration) {
            self.configuration = configuration
        }
        
        var body: some View {
            applyButtonStyle(configuration.label,
                             isPressed: configuration.isPressed,
                             isEnabled: isEnabled)
        }
    }
}

extension SwiftUI.View {
    
    func primerButtonStyle() -> some View {
        return buttonStyle(CustomButtonStyle())
    }
}
