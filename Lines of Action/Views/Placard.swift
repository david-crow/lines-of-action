//
//  Placard.swift
//  Lines of Action
//
//  Created by David Crow on 7/10/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Placard: View {
    @ObservedObject var viewModel: LinesOfActionViewModel
    
    var body: some View {
        HStack {
            body(for: .player)
            Spacer()
            body(for: .opponent)
        }
    }
    
    private func body(for player: LinesOfAction.Player) -> some View {
        HStack {
            if player == .player {
                PieceIcon(player: player, maxDiameter: maxDiameter)
                Text(viewModel.name(for: .player)).font(fontSize)
            } else {
                Text(viewModel.name(for: .opponent)).font(fontSize)
                PieceIcon(player: .opponent, maxDiameter: maxDiameter)
            }
        }
        .padding(contentPadding)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(viewModel.isActive(player) ? borderColor : Color.clear, lineWidth: borderWidth)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Drawing Constants
    
    private let maxDiameter: CGFloat = 25
    private let fontSize: Font = .body
    private let contentPadding: CGFloat = 10
    private let cornerRadius: CGFloat = 10
    private let borderColor: Color = .yellow
    private let borderWidth: CGFloat = 2
}
