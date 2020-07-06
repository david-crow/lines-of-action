//
//  LinesOfActionGameView.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct LinesOfActionGameView: View {
    @ObservedObject var viewModel: LinesOfActionGame
    
    var body: some View {
        ZStack {
            Board()
                .environmentObject(viewModel)
                .padding()
        }
    }
}

struct Board: View {
    @EnvironmentObject var viewModel: LinesOfActionGame
        
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    private func body(for size: CGSize) -> some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<self.viewModel.boardSize) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<self.viewModel.boardSize) { col in
                            Rectangle().fill(self.color(for: Square(x: row, y: col)))
                        }
                    }
                }
            }
            
            ForEach(viewModel.pieces, id: \.self) { piece in
                Piece(piece, size: size, boardSize: self.viewModel.boardSize)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(Rectangle().stroke())
    }
    
    struct Square {
        let x: Int
        let y: Int
    }
        
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
            ZStack {
                Circle().frame(width: outerPieceSize, height: outerPieceSize).foregroundColor(color)
                Circle().frame(width: middlePieceSize, height: middlePieceSize).foregroundColor(.white)
                Circle().frame(width: innerPieceSize, height: innerPieceSize).foregroundColor(color)
                Circle().frame(width: emblemPieceSize, height: emblemPieceSize).foregroundColor(.white)
            }
            .offset(CGSize(width: xOffset, height: yOffset))
        }
        
        // MARK: - Drawing Constants (Sizing)
        
        private var diameter: CGFloat {
            min(size.width, size.height) / CGFloat(boardSize)
        }
        
        private var outerPieceSize: CGFloat {
            0.9 * diameter
        }
        
        private var middlePieceSize: CGFloat {
            0.7 * diameter
        }
        
        private var innerPieceSize: CGFloat {
            0.6 * diameter
        }
        
        private var emblemPieceSize: CGFloat {
            0.3 * diameter
        }
        
        // MARK: - Drawing Constants (Positioning)
        
        private var xOffset: CGFloat {
            let centerline = 0.5 * (CGFloat(boardSize) - 1)
            let colOffset = centerline - CGFloat(piece.x)
            return diameter * colOffset
        }
        
        private var yOffset: CGFloat {
            let centerline = 0.5 * (CGFloat(boardSize) - 1)
            let rowOffset = centerline - CGFloat(piece.y)
            return diameter * rowOffset
        }
        
        // MARK: - Drawing Constants (Other)
        
        private var color: Color {
            piece.player == .player ? .red : .blue
        }
    }
    
    // MARK: - Drawing Constants
    
    private func color(for square: Square) -> Color {
        (square.x + square.y) % 2 == 0 ? .white : .black
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = LinesOfActionGame()
        return LinesOfActionGameView(viewModel: game)
    }
}
