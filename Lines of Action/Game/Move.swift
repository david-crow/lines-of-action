//
//  Move.swift
//  Lines of Action
//
//  Created by David Crow on 10/15/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

struct Move {
    typealias Piece = GameBoard.Piece
    typealias Square = GameBoard.Square
    
    let piece: Piece
    let oldLocation: Square
    let newLocation: Square
    var capturedPiece = false
    var value: Double = 0
    
    init(_ piece: Piece, to destination: Square) {
        self.piece = piece
        self.oldLocation = piece.location
        self.newLocation = destination
    }
    
    init(other: Move, value: Double) {
        self.piece = other.piece
        self.oldLocation = other.oldLocation
        self.newLocation = other.newLocation
        self.capturedPiece = other.capturedPiece
        self.value = value
    }
}
