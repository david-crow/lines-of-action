//
//  Board.swift
//  Lines of Action
//
//  Created by David Crow on 7/10/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Board: View {
    @EnvironmentObject var viewModel: LinesOfActionViewModel
        
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
                            Square(col, row, size: size)
                                .environmentObject(self.viewModel)
                                .overlay(Rectangle().stroke(Color.black))
                                .onTapGesture { self.viewModel.selectSquare(x: col, y: row) }
                        }
                    }
                }
            }

            ForEach(viewModel.pieces, id: \.self) { piece in
                Piece(piece, size: size, boardSize: self.viewModel.boardSize)
                    .allowsHitTesting(false)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
