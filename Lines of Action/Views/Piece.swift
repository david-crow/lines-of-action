//
//  Piece.swift
//  Lines of Action
//
//  Created by David Crow on 7/9/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Piece: View {
    @EnvironmentObject var viewModel: LinesOfActionViewModel
    
    let piece: LinesOfAction.Piece
    let size: CGSize
    
    init(_ piece: LinesOfAction.Piece, size: CGSize) {
        self.piece = piece
        self.size = size
    }
    
    var body: some View {
        PieceIcon(icon: viewModel.icon, colors: (color, highlightColor), maxDiameter: squareSize).position(pieceLocation)
    }
    
    // MARK: - Drawing Constants
    
    private var color: Color {
        piece.player == .player ? viewModel.theme.playerColor : viewModel.theme.opponentColor
    }
    
    private var highlightColor: Color {
        let isHighlighted = piece.player == viewModel.winner && viewModel.inFinalState
        return isHighlighted ? viewModel.theme.highlightColor : .clear
    }
    
    private var squareSize: CGFloat {
        min(size.width, size.height) / CGFloat(viewModel.boardSize)
    }
    
    private var pieceLocation: CGPoint {
        let colOffset = 0.5 + CGFloat(piece.location.x)
        let rowOffset = 0.5 + CGFloat(piece.location.y)
        return CGPoint(x: squareSize * colOffset, y: squareSize * rowOffset)
    }
}

struct PieceIcon: View {
    let icon: String
    let color: Color
    let highlightColor: Color?
    let maxDiameter: CGFloat
    
    init(icon: String, color: Color, maxDiameter: CGFloat) {
        self.icon = icon
        self.color = color
        self.highlightColor = nil
        self.maxDiameter = maxDiameter
    }
    
    init(icon: String, colors: (color: Color, highlightColor: Color?), maxDiameter: CGFloat) {
        self.icon = icon
        self.color = colors.color
        self.highlightColor = colors.highlightColor
        self.maxDiameter = maxDiameter
    }
    
    var body: some View {
        ZStack {
            if highlightColor != nil {
                Circle()
                    .fill(highlightColor!)
                    .frame(width: highlightSize, height: highlightSize)
            }
            
            Circle()
                .fill(color)
                .frame(width: outerPieceSize, height: outerPieceSize)
            Circle()
                .fill(Color.white)
                .frame(width: middlePieceSize, height: middlePieceSize)
            Circle()
                .fill(color)
                .frame(width: innerPieceSize, height: innerPieceSize)
            Image(systemName: icon)
                .resizable()
                .foregroundColor(.white)
                .frame(width: emblemPieceSize, height: emblemPieceSize)
        }
    }
    
    // MARK: - Drawing Constants
    
    private var highlightSize: CGFloat {
        0.9 * maxDiameter
    }
    
    private var outerPieceSize: CGFloat {
        0.8 * maxDiameter
    }
    
    private var middlePieceSize: CGFloat {
        0.8 * outerPieceSize
    }
    
    private var innerPieceSize: CGFloat {
        0.9 * middlePieceSize
    }
    
    private var emblemPieceSize: CGFloat {
        0.7 * innerPieceSize
    }
}
