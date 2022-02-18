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
            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<viewModel.boardSize) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<viewModel.boardSize) { col in
                                Square(col, row, size: geometry.size)
                                    .environmentObject(viewModel)
                            }
                        }
                    }
                }

                ForEach(viewModel.pieces, id: \.self) { piece in
                    Piece(piece, size: geometry.size)
                        .environmentObject(viewModel)
                        .allowsHitTesting(false)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}
