//
//  LinesOfAction.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

struct LinesOfAction {
    // MARK: - Stored and Computed Variables
    
    let boardSize: Int

    private(set) var pieces: [Piece]

    // MARK: - Initializers
    
    init(boardSize: Int = 8) {
        self.boardSize = boardSize
        pieces = LinesOfAction.createGame(size: boardSize)
    }
    
    // MARK: - Type and Instance Methods
    
    static private func createGame(size: Int) -> [Piece] {
        var pieces: [Piece] = []
        
        for row in [0, size - 1] {
            for col in 1..<size-1 {
                pieces.append(Piece(x: col, y: row, player: .player))
            }
        }
        
        for row in 1..<size-1 {
            for col in [0, size - 1] {
                pieces.append(Piece(x: col, y: row, player: .opponent))
            }
        }
        
        return pieces
    }
    
    func pieceAt(_ x: Int, _ y: Int) -> Piece? {
        for piece in pieces {
            if piece.x == x && piece.y == y {
                return piece
            }
        }
        
        return nil
    }
    
    mutating func select(_ piece: Piece) {
        if let piece = pieces.firstIndex(matching: piece) {
            pieces[piece].isSelected = !pieces[piece].isSelected
        }
    }
        
    // MARK: - Structs and Enumerations
    
    struct Piece: Identifiable, Hashable {
        let x: Int
        let y: Int
        var player: Player
        var isSelected = false
        var id = UUID()
    }
    
    enum Player: String {
        case player, opponent
    }
}
