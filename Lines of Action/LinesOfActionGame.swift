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
    
    func select(_ piece: LinesOfAction.Piece) {
        model.select(piece)
    }
}
