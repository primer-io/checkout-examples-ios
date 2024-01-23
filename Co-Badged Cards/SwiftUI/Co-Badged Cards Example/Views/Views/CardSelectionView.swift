//
//  CardSelectionView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 01/11/2023.
//

import SwiftUI
import PrimerSDK

struct CardDisplayModel {
    let index: Int
    let name: String
    let image: UIImage?
    
    let value: CardNetwork
    
    var uiImage: UIImage {
        if let image = image {
            return image
        } else {
            return UIImage(named: "UnknownCard")!
        }
    }
}

struct CardView: View {
    
    let card: CardDisplayModel
    
    var body: some View {
        Image(uiImage: card.uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 32)
            .clipShape(clipShape)
            .overlay(border)
    }
    
    private var border: some View {
        clipShape.stroke(.gray, lineWidth: 1)
    }
    
    private var clipShape: some Shape {
        RoundedRectangle(cornerRadius: 4)
    }
    
}

struct CardSelectionView: View {
    
    @Binding var cards: [CardDisplayModel]
    
    @State var selectedIndex: Int = 0
    
    let isLoading: Bool
    
    let onChange: (Int) -> Void

    init(cards: Binding<[CardDisplayModel]>, isLoading: Bool, onChange: @escaping (Int) -> Void) {
        self._cards = cards
        self.selectedIndex = 0
        self.isLoading = isLoading
        self.onChange = onChange
    }
        
    var body: some View {
        HStack(spacing: 4) {
            if isLoading {
                ProgressView()
            } else {
                ForEach(cards, id: \.name) { card in
                    CardView(card: card)
                        .opacity(cards.count == 1 || card.index == selectedIndex ? 1 : 0.5)
                        .animation(.easeIn(duration: 0.1), value: selectedIndex)
                        .onTapGesture { didTapCard(card) }
                }
            }
        }
        .frame(maxHeight: 32)
        .padding(2)
    }
    
    func didTapCard(_ card: CardDisplayModel) {
        selectedIndex = card.index
        onChange(selectedIndex)
    }
}

#Preview {
    CardSelectionView(cards: .constant([
        CardDisplayModel(index: 0, name: "MasterCard", image: .init(), value: .masterCard),
        CardDisplayModel(index: 1, name: "VISA", image: .init(), value: .visa)
    ]), isLoading: false) { _ in }
}
