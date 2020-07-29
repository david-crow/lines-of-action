//
//  Square.swift
//  Lines of Action
//
//  Created by David Crow on 7/9/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Square: View {
    @EnvironmentObject var viewModel: LinesOfActionViewModel
    
    let col: Int
    let row: Int
    let size: CGSize
    
    init(_ col: Int, _ row: Int, size: CGSize) {
        self.col = col
        self.row = row
        self.size = size
    }

    var body: some View {
        ZStack {
            Rectangle().fill(isSelected ? Color.yellow : color)
            
            if hasToken {
                Token(size: tokenSize, color: tokenColor)
                    .offset(hasPiece ? CGSize(width: tokenOffset, height: -tokenOffset) : CGSize(width: 0, height: 0))
            }
        }
    }
    
    private var isSelected: Bool {
        !viewModel.gameIsOver && viewModel.isSelected(x: col, y: row)
    }
    
    private var color: Color {
        colorForSquare(x: col, y: row)
    }
    
    private var hasToken: Bool {
        !viewModel.gameIsOver && viewModel.showValidMoves && viewModel.canMoveTo(x: col, y: row)
    }
    
    private var hasPiece: Bool {
        viewModel.pieceAt(x: col, y: row) != nil
    }
    
    struct Token: View {
        let size: CGFloat
        let color: Color
        
        var body: some View {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
    }
    
    // MARK: - Drawing Constants
    
    private let tokenScale: CGFloat = 0.15
    private let tokenColor: Color = .yellow
    
    private var squareSize: CGFloat {
        min(size.width, size.height) / CGFloat(viewModel.boardSize)
    }
    
    private var tokenSize: CGFloat {
        tokenScale * squareSize
    }
    
    private var tokenOffset: CGFloat {
        0.5 * squareSize - 0.75 * tokenSize
    }
    
    private func colorForSquare(x: Int, y: Int) -> Color {
        (x + y) % 2 == 0 ? Color(UIColor.systemGray) : Color(UIColor.systemGray2)
    }
}
