//
//  LinesOfActionGame.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

class LinesOfActionGame: ObservableObject {
    @Published private var model: LinesOfAction = LinesOfAction()
    
    // MARK: - Access to the Model
    
    var boardSize: Int {
        model.boardSize
    }
    
    var squares: [LinesOfAction.Square] {
        model.squares
    }
    
    var pieces: [LinesOfAction.Piece] {
        model.pieces
    }
    
    func isSelected(x: Int, y: Int) -> Bool {
        model.isSelected(x, y)
    }
    
    func pieceAt(x: Int, y: Int) -> LinesOfAction.Piece? {
        model.pieceAt(x, y)
    }
    
    func canMoveTo(x: Int, y: Int) -> Bool {
        model.canMoveTo(x, y)
    }
    
    // MARK: - Intent(s)
    
    func selectSquare(x: Int, y: Int) {
        if let tappedPiece = model.pieceAt(x, y) {
            if model.selectedPieceIndex != nil && model.canMoveTo(x, y) {
                model.moveTo(x, y)
            } else {
                model.select(tappedPiece)
            }
        } else if model.selectedPieceIndex != nil {
            if model.canMoveTo(x, y) {
                model.moveTo(x, y)
            } else {
                model.deselectAllPieces()
            }
        }
    }
    
    func select(_ piece: LinesOfAction.Piece) {
        model.select(piece)
    }
    
    func moveTo(x: Int, y: Int) {
        model.moveTo(x, y)
    }
}
