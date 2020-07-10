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
                            Square(
                                hasPiece: self.viewModel.pieceAt(x: col, y: row) != nil,
                                color: self.color(for: LinesOfAction.Square(col, row)),
                                selected: self.viewModel.isSelected(x: col, y: row),
                                highlighted: self.viewModel.canMoveTo(x: col, y: row),
                                boardSize: self.viewModel.boardSize,
                                size: size
                            )
                                .environmentObject(self.viewModel)
                        }
                    }
                }
            }
            
            ForEach(viewModel.pieces, id: \.self) { piece in
                Piece(piece, size: size, boardSize: self.viewModel.boardSize)
                    .onTapGesture {
                        self.viewModel.select(piece)
                    }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(Rectangle().stroke())
    }
    
    // MARK: - Drawing Constants
        
    private func color(for square: LinesOfAction.Square) -> Color {
        (square.x + square.y) % 2 == 0 ? Color(UIColor.systemGray) : Color(UIColor.systemGray2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = LinesOfActionGame()
        return LinesOfActionGameView(viewModel: game)
    }
}
