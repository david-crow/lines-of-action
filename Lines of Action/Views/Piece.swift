//
//  Piece.swift
//  Lines of Action
//
//  Created by David Crow on 7/9/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Piece: View {
    let piece: LinesOfAction.Piece
    let size: CGSize
    let boardSize: Int
    
    init(_ piece: LinesOfAction.Piece, size: CGSize, boardSize: Int) {
        self.piece = piece
        self.size = size
        self.boardSize = boardSize
    }
    
    var body: some View {
        PieceIcon(player: piece.player, maxDiameter: squareSize)
            .offset(CGSize(width: xOffset, height: yOffset))
    }
    
    // MARK: - Drawing Constants
    
    private var squareSize: CGFloat {
        min(size.width, size.height) / CGFloat(boardSize)
    }
    
    private var xOffset: CGFloat {
        let centerline = 0.5 * (CGFloat(boardSize) - 1)
        let colOffset = centerline - CGFloat(piece.location.x)
        return -squareSize * colOffset
    }
    
    private var yOffset: CGFloat {
        let centerline = 0.5 * (CGFloat(boardSize) - 1)
        let rowOffset = centerline - CGFloat(piece.location.y)
        return -squareSize * rowOffset
    }
}

struct PieceIcon: View {
    let player: LinesOfAction.Player
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
    
    private var color: Color {
        player == .player ? .red : .blue
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
