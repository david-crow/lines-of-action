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
    
    var body: some View {
        VStack {
            PieceIcon(icon: viewModel.icon, color: pieceColor, maxDiameter: pieceDiameter)
            Text("Winner!").font(winnerFont).foregroundColor(.black)
            Text("\(winnerName)").font(nameFont).foregroundColor(.black)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .overlay(
            VStack {
                HStack {
                    Button(action: {},
                           label: { Image(systemName: "square.and.arrow.up").imageScale(.large) })
                    Spacer()
                    Button(action: { viewModel.analyze() },
                           label: { Image(systemName: "xmark").imageScale(.large) })
                }
                
                Spacer()
            }
            .padding()
        )
        .background(
            RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
        )
    }
    
    // MARK: - Drawing Constants
    
    private let winnerFont: Font = Font.title.weight(.semibold)
    private let nameFont: Font = Font.subheadline.weight(.semibold)
    private let cornerRadius: CGFloat = 15
    private let pieceDiameter: CGFloat = 70
    private let horizontalPadding: CGFloat = 40
    private let verticalPadding: CGFloat = 20
    
    private var winnerName: String {
        viewModel.winner == .player ? viewModel.name(for: .player) : viewModel.name(for: .opponent)
    }
    
    private var pieceColor: Color {
        viewModel.winner == .player ? viewModel.theme.playerColor : viewModel.theme.opponentColor
    }
}
