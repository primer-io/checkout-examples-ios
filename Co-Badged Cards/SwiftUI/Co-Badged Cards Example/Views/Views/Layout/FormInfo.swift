//
//  FormInfo.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 06/12/2023.
//

import SwiftUI

struct FormInfo<Content>: View where Content: View {
    
    let content: Content 
    
    @inlinable public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Section { EmptyView() } header: {
            VStack(alignment: .leading) {
                content
            }
            .textCase(nil)
            .textScale(.secondary)
        }
    }
}
