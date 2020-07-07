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
    
    func pieceAt(_ x: Int, _ y: Int) -> LinesOfAction.Piece? {
        model.pieceAt(x, y)
    }
    
    // MARK: - Intent(s)
    
    func select(_ piece: LinesOfAction.Piece) {
        model.select(piece)
    }
}
