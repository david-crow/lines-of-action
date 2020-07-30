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
        PieceIcon(color: color, maxDiameter: squareSize).position(pieceLocation)
    }
    
    private var color: Color {
        piece.player == .player ? viewModel.theme.playerColor : viewModel.theme.opponentColor
    }
    
    // MARK: - Drawing Constants
    
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
    let color: Color
    let maxDiameter: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: outerPieceSize, height: outerPieceSize)
            Circle()
                .fill(Color.white)
                .frame(width: middlePieceSize, height: middlePieceSize)
            Circle()
                .fill(color)
                .frame(width: innerPieceSize, height: innerPieceSize)
            Star(corners: numStarCorners, smoothness: starSmoothness)
                .fill(Color.white)
                .frame(width: emblemPieceSize, height: emblemPieceSize)
        }
    }
    
    // MARK: - Drawing Constants
    
    private let numStarCorners = 5
    private let starSmoothness: CGFloat = 0.45
    
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
