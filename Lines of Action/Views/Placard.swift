//
//  Placard.swift
//  Lines of Action
//
//  Created by David Crow on 7/10/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Placard: View {
    let player: LinesOfAction.Player
    let activePlayer: LinesOfAction.Player
    
    init(for player: LinesOfAction.Player, activePlayer: LinesOfAction.Player) {
        self.player = player
        self.activePlayer = activePlayer
    }
    
    var body: some View {
        HStack {
            if player == .player {
                PieceIcon(player: player, maxDiameter: maxDiameter)
                Text(title).font(fontSize)
            } else {
                Text(title).font(fontSize)
                PieceIcon(player: .opponent, maxDiameter: maxDiameter)
            }
        }
        .padding(contentPadding)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(player == activePlayer ? borderColor : Color.clear, lineWidth: borderWidth)
        )
        .padding(paddingSet)
    }
    
    // MARK: - Drawing Constants
    
    private let maxDiameter: CGFloat = 25
    private let fontSize: Font = .body
    private let contentPadding: CGFloat = 10
    private let cornerRadius: CGFloat = 10
    private let borderColor: Color = .yellow
    private let borderWidth: CGFloat = 2
    
    private var title: String {
        player == .player ? "Player" : "Opponent"
    }
    
    private var paddingSet: Edge.Set {
        player == .player ? .leading : .trailing
    }
}
