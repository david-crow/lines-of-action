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
    
    var board: [LinesOfAction.Square] {
        model.board
    }
    
    var boardSize: Int {
        model.boardSize
    }
    
    func squareAt(_ x: Int, _ y: Int) -> LinesOfAction.Square {
        model.squareAt(x, y)
    }
}
