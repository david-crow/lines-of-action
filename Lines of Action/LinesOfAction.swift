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
    
    private var squares: [Square]

    private(set) var pieces: [Piece]
        
    private(set) var selectedPieceIndex: Int? {
        get { pieces.indices.filter { pieces[$0].isSelected }.only }
        set {
            for index in pieces.indices {
                pieces[index].isSelected = index == newValue
            }
        }
    }

    // MARK: - Initializers
    
    init(boardSize: Int = 8) {
        self.boardSize = boardSize
        (pieces, squares) = LinesOfAction.createGame(size: boardSize)
    }
    
    // MARK: - Type and Instance Methods
    
    static private func createGame(size: Int) -> ([Piece], [Square]) {
        var pieces: [Piece] = []
        var squares: [Square] = []
        
        for row in [0, size - 1] {
            for col in 1 ..< size - 1 {
                pieces.append(Piece(location: Square(col, row), player: .player))
            }
        }
        
        for row in 1 ..< size - 1 {
            for col in [0, size - 1] {
                pieces.append(Piece(location: Square(col, row), player: .opponent))
            }
        }
        
        for row in 0..<size {
            for col in 0..<size {
                squares.append(Square(col, row))
            }
        }
        
        return (pieces, squares)
    }
    
    func isSelected(_ x: Int, _ y: Int) -> Bool {
        if let index = selectedPieceIndex {
            return pieces[index] == pieceAt(x, y)
        }
        return false
    }
    
    func pieceAt(_ x: Int, _ y: Int) -> Piece? {
        for piece in pieces {
            if piece.location.x == x && piece.location.y == y {
                return piece
            }
        }
        return nil
    }
    
    func canMoveTo(_ x: Int, _ y: Int) -> Bool {
        if let index = selectedPieceIndex {
            let piece = pieces[index]
            let location = Square(x, y)
            return canMove(piece, to: location) && validMove(piece, movingTo: location)
        }
        return false
    }
    
    private func canMove(_ piece: Piece, to location: Square) -> Bool {
        canMoveHorizontally(piece, to: location) || canMoveVertically(piece, to: location) || canMoveDiagonally(piece, to: location)
    }
    
    private func canMoveHorizontally(_ piece: Piece, to location: Square) -> Bool {
        let colDistance = pieces.filter { $0.location.x == piece.location.x }.count
        return piece.location.x == location.x && abs(piece.location.y - location.y) == colDistance
    }
    
    private func canMoveVertically(_ piece: Piece, to location: Square) -> Bool {
        let rowDistance = pieces.filter { $0.location.y == piece.location.y }.count
        return piece.location.y == location.y && abs(piece.location.x - location.x) == rowDistance
    }
    
    private func canMoveDiagonally(_ piece: Piece, to location: Square) -> Bool {
        let posDiagonalDistance = pieces.filter { $0.location.x - piece.location.x == piece.location.y - $0.location.y }.count
        let negDiagonalDistance = pieces.filter { $0.location.x - piece.location.x == $0.location.y - piece.location.y }.count
        return location.x - piece.location.x == posDiagonalDistance && piece.location.y - location.y == posDiagonalDistance
            || piece.location.x - location.x == posDiagonalDistance && location.y - piece.location.y == posDiagonalDistance
            || location.x - piece.location.x == negDiagonalDistance && location.y - piece.location.y == negDiagonalDistance
            || piece.location.x - location.x == negDiagonalDistance && piece.location.y - location.y == negDiagonalDistance
    }
    
    private func validMove(_ piece: Piece, movingTo location: Square) -> Bool {
        !landingOnPlayer(piece, movingTo: location) && !jumpingOpponent(piece, movingTo: location)
    }
    
    private func landingOnPlayer(_ piece: Piece, movingTo location: Square) -> Bool {
        piece.player == pieceAt(location.x, location.y)?.player
    }
    
    private func jumpingOpponent(_ piece: Piece, movingTo location: Square) -> Bool {
        var squaresOnPath: Set<Square>
        let opponentSquares = Set(opponentPieces(for: piece.player).map { $0.location })

        if piece.location.x == location.x {
            squaresOnPath = Set(squaresInColumnBetween(a: piece.location, b: location))
        } else if piece.location.y == location.y {
            squaresOnPath = Set(squaresInRowBetween(a: piece.location, b: location))
        } else {
            squaresOnPath = Set(squaresOnDiagonalBetween(a: piece.location, b: location))
        }
        
        return squaresOnPath.intersection(opponentSquares).count > 0
    }
    
    private func playerPieces(for player: Player) -> [Piece] {
        pieces.filter { $0.player == player }
    }
    
    private func opponentPieces(for player: Player) -> [Piece] {
        pieces.filter { $0.player != player }
    }
    
    private func squaresInColumnBetween(a: Square, b: Square) -> [Square] {
        let squaresInColumn = squares.filter { $0.x == a.x && $0.x == b.x }
        
        if a.y < b.y {
            return squaresInColumn.filter { $0.y > a.y && $0.y < b.y }
        } else {
            return squaresInColumn.filter { $0.y < a.y && $0.y > b.y }
        }
    }
    
    private func squaresInRowBetween(a: Square, b: Square) -> [Square] {
        let squaresInRow = squares.filter { $0.y == a.y && $0.y == b.y }
        
        if a.x < b.x {
            return squaresInRow.filter { $0.x > a.x && $0.x < b.x }
        } else {
            return squaresInRow.filter { $0.x < a.x && $0.x > b.x }
        }
    }
    
    private func squaresOnDiagonalBetween(a: Square, b: Square) -> [Square] {
        if a.x < b.x {
            if a.y > b.y { // b is northeast of a
                return squares.filter { $0.x > a.x && $0.x < b.x && $0.y < a.y && $0.y > b.y && abs($0.x - a.x) == abs($0.y - a.y) }
            } else { // b is southeast of a
                return squares.filter { $0.x > a.x && $0.x < b.x && $0.y > a.y && $0.y < b.y && abs($0.x - a.x) == abs($0.y - a.y) }
            }
        } else {
            if a.y > b.y { // b is northwest of a
                return squares.filter { $0.x < a.x && $0.x > b.x && $0.y < a.y && $0.y > b.y && abs($0.x - a.x) == abs($0.y - a.y) }
            } else { // b is southwest of a
                return squares.filter { $0.x < a.x && $0.x > b.x && $0.y > a.y && $0.y < b.y && abs($0.x - a.x) == abs($0.y - a.y) }
            }
        }
    }
    
    mutating func select(_ piece: Piece) {
        if let index = pieces.firstIndex(matching: piece) {
            selectedPieceIndex = piece.isSelected ? nil : index
        }
    }
        
    // MARK: - Structs and Enumerations
    
    struct Square: Equatable, Hashable {
        let x: Int
        let y: Int
        
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
    }
    
    struct Piece: Identifiable, Hashable {
        let location: Square
        let player: Player
        var isSelected = false
        let id = UUID()
    }
    
    enum Player: String {
        case player, opponent
    }
}
