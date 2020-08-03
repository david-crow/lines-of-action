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
            Rectangle().fill(squareColor)
            SquareEmphasis(for: isSelected, color: selectedColor)
            SquareEmphasis(for: isLastMove, color: highlightColor)
            SquareEmphasis(for: isDestination, color: highlightColor)
        }
        .overlay(Rectangle().stroke())
        .onTapGesture { self.viewModel.selectSquare(x: self.col, y: self.row) }
    }
    
    private var isSelected: Bool {
        viewModel.gameMode == .playing && viewModel.isSelected(x: col, y: row)
    }
    
    private var isLastMove: Bool {
        viewModel.gameMode == .playing && viewModel.showingLastMove && viewModel.isLastMove(x: col, y: row)
    }
    
    private var isDestination: Bool {
        viewModel.gameMode == .playing && viewModel.showValidMoves && viewModel.canMoveTo(x: col, y: row)
    }

    // MARK: - Drawing Constants

    private var squareColor: Color {
        (col + row) % 2 == 0 ? viewModel.theme.firstSquareColor : viewModel.theme.secondSquareColor
    }

    private var selectedColor: Color {
        viewModel.activeColor
    }

    private var highlightColor: Color {
        viewModel.theme.highlightColor
    }
}

fileprivate struct SquareEmphasis: View {
    let flag: Bool
    let color: Color

    init(for flag: Bool, color: Color) {
        self.flag = flag
        self.color = color
    }

    var body: some View {
        ZStack {
            Rectangle().opacity(opacity)
            Rectangle().stroke(lineWidth: borderWidth).clipped()
        }
        .foregroundColor(flag ? color : .clear)
    }

    // MARK: - Drawing Constants

    private let opacity: Double = 0.5
    private let borderWidth: CGFloat = 5
}
