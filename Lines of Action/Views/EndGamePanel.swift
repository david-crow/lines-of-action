//
//  EndGamePanel.swift
//  Lines of Action
//
//  Created by David Crow on 7/26/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct EndGamePanel: View {
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var viewModel: LinesOfActionViewModel
    
    let size: CGSize
    
    var body: some View {
        VStack {
            HStack {
                PieceIcon(color: pieceColor, maxDiameter: pieceDiameter)
                Text("Winner!").font(winnerFont).foregroundColor(.black)
                PieceIcon(color: pieceColor, maxDiameter: pieceDiameter)
            }
            
            Group {
                Button("New Game") { self.viewModel.resetGame() }
                Button("Analysis") { self.viewModel.didAnalyze = true }
                Button("Main Menu") { self.presentation.wrappedValue.dismiss() }
            }
            .padding(buttonPadding)
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .shadow(radius: 3)
            }
        )
    }
    
    // MARK: - Drawing Constants
    
    private let cornerRadius: CGFloat = 10
    private let strokeWidth: CGFloat = 2
    private let pieceDiameter: CGFloat = 40
    private let winnerFont: Font = Font.title.weight(.semibold)
    private let buttonPadding: CGFloat = 5
    
    private var panelWidth: CGFloat {
        5 / 8 * min(size.width, size.height)
    }
    
    private var panelHeight: CGFloat {
        3 / 8 * min(size.width, size.height)
    }
    
    private var pieceColor: Color {
        viewModel.winner == .player ? viewModel.theme.playerColor : viewModel.theme.opponentColor
    }
}
