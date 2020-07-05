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
        Board(boardSize: viewModel.boardSize)
            .environmentObject(viewModel)
            .padding()
    }
}

struct Board: View {
    @EnvironmentObject var viewModel: LinesOfActionGame
    
    let boardSize: Int
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    private func body(for size: CGSize) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<self.viewModel.boardSize) { row in
                HStack(spacing: 0) {
                    ForEach(0..<self.viewModel.boardSize) { col in
                        self.body(for: self.viewModel.squareAt(row, col), size: size)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func body(for square: LinesOfAction.Square, size: CGSize) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(self.color(for: square))
                .overlay(
                    Rectangle().stroke()
                )

            Circle()
                .foregroundColor(self.color(for: square.player))
                .frame(width: self.pieceScale * self.squareSideLength(for: size),
                       height: self.pieceScale * self.squareSideLength(for: size))
        }
    }
    
    // MARK: - Drawing Constants
    
    private let pieceScale: CGFloat = 0.7
    
    private func squareSideLength(for size: CGSize) -> CGFloat {
        min(size.width, size.height) / CGFloat(boardSize)
    }
    
    private func color(for square: LinesOfAction.Square) -> Color {
        (square.x + square.y) % 2 == 0 ? .white : .black
    }
    
    private func color(for player: LinesOfAction.Player?) -> Color {
        if let player = player {
            return player == .player ? .red : .blue
        }
        return .clear
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = LinesOfActionGame()
        return LinesOfActionGameView(viewModel: game)
    }
}
