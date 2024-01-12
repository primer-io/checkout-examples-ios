//
//  AllowedNetworksView.swift
//  Co-Badged Cards Example
//
//  Created by Jack Newcombe on 22/11/2023.
//

import SwiftUI
import PrimerSDK

struct AllowedNetworksView: View {
    var body: some View {
        HStack {
            ForEach(assets, id: \.cardNetwork.rawValue) { asset in
                if let image = asset.cardImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5)))
                }
            }
            Spacer()
        }
        .frame(height: 28)
    }
    
    var assets: [PrimerCardNetworkAsset] {
        do {
            let assets = try PrimerHeadlessUniversalCheckout.AssetsManager.getAllowedCardNetworkAssets()
            return Array(assets)
        } catch {
            logger.error("failed to get assets - \(error.localizedDescription)")
            return []
        }
    }
}

#Preview {
    AllowedNetworksView()
}
