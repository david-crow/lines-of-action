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
    
    private(set) var board: [Square]
    
    // MARK: - Initializers
    
    init(boardSize: Int = 8) {
        self.boardSize = boardSize
        board = LinesOfAction.createBoard(size: boardSize)
    }
    
    // MARK: - Type and Instance Methods
    
    static private func createBoard(size: Int) -> [Square] {
        var squares: [Square] = []
        
        // top and bottom rows
        for row in 1..<size-1 {
            for col in 1..<size-1 { // empty squares
                squares.append(Square(x: row, y: col))
            }
            for col in [0, size-1] { // pieces
                squares.append(Square(x: row, y: col, player: .player))
            }
        }
        
        // middle rows
        for row in [0, size-1] {
            for col in [0, size-1] { // empty squares
                squares.append(Square(x: row, y: col))
            }
            for col in 1..<size-1 { // pieces
                squares.append(Square(x: row, y: col, player: .opponent))
            }
        }
        
        return squares.sorted {
            if $0.y < $1.y {
                return true
            } else if $0.y == $1.y && $0.x < $1.x {
                return true
            }
            return false
        }
    }
    
    func squareAt(_ x: Int, _ y: Int) -> Square {
        board[x * boardSize + y]
    }
        
    // MARK: - Structs and Enumerations
    
    struct Square: Hashable {
        let x: Int
        let y: Int
        var player: Player?
    }
    
    enum Player {
        case player, opponent
    }
}
