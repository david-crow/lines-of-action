//
//  GameView.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: LinesOfActionViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Placard(for: .player, activePlayer: viewModel.activePlayer)
                    Spacer()
                    Placard(for: .opponent, activePlayer: viewModel.activePlayer)
                }
                
                Board()
                    .environmentObject(viewModel)
                    .frame(maxWidth: UIScreen.main.bounds.width,
                           maxHeight: UIScreen.main.bounds.width)
            }
            
            if viewModel.winner != nil {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(maxHeight: winnerBarHeight)

                    HStack {
                        PieceIcon(player: viewModel.winner!, maxDiameter: winnerBarPieceDiameter)
                        Text("Winner!").font(.largeTitle)
                        PieceIcon(player: viewModel.winner!, maxDiameter: winnerBarPieceDiameter)
                    }
                }
            }
        }
    }
    
    // MARK: - Drawing Constants
    
    private var winnerBarHeight: CGFloat {
        0.1 * UIScreen.main.bounds.width
    }
    
    private var winnerBarPieceDiameter: CGFloat {
        0.75 * winnerBarHeight
    }
}
