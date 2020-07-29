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
    
    let winner: LinesOfAction.Player
    let size: CGSize
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
            RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: strokeWidth)
            
            VStack {
                HStack {
                    PieceIcon(player: winner, maxDiameter: pieceDiameter)
                    Text("Winner!").font(winnerFont)
                    PieceIcon(player: winner, maxDiameter: pieceDiameter)
                }
                
                Group {
                    Button("New Game") { self.viewModel.resetGame() }
                    Button("Analyze") { self.viewModel.analyze() }
                    Button("Main Menu") { self.presentation.wrappedValue.dismiss() }
                }
                .padding(buttonPadding)
                
            }
            .padding()
        }
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
}
