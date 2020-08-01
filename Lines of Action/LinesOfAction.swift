//
//  LinesOfAction.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

struct LinesOfAction {
    // MARK: - Variables
    
    let boardSize: Int
    
    private(set) var winner: Player?
    private(set) var activePlayer: Player = .player
    private(set) var moves: [Move] = []
    private(set) var squares: [Square]
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
    
    // MARK: - Type Methods
    
    static private func createGame(size: Int) -> ([Piece], [Square]) {
        var pieces: [Piece] = []
        var squares: [Square] = []
        
        for row in [0, size - 1] {
            for col in 1 ..< size - 1 {
                pieces.append(Piece(player: .player, location: Square(col, row)))
            }
        }
        
        for row in 1 ..< size - 1 {
            for col in [0, size - 1] {
                pieces.append(Piece(player: .opponent, location: Square(col, row)))
            }
        }
        
        for row in 0..<size {
            for col in 0..<size {
                squares.append(Square(col, row))
            }
        }
        
        return (pieces, squares)
    }
    
    // MARK: - Instance Methods
    
    func isSelected(_ x: Int, _ y: Int) -> Bool {
        if let index = selectedPieceIndex {
            return pieces[index] == pieceAt(x, y)
        }
        return false
    }
    
    func isLastMove(_ x: Int, _ y: Int) -> Bool {
        if let previousMove = moves.last {
            let square = Square(x, y)
            return square == previousMove.oldLocation || square == previousMove.newLocation
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
    
    func pieceAt(_ location: Square) -> Piece? {
        for piece in pieces {
            if piece.location.x == location.x && piece.location.y == location.y {
                return piece
            }
        }
        return nil
    }
    
    func canMoveTo(_ x: Int, _ y: Int) -> Bool {
        if let index = selectedPieceIndex {
            let piece = pieces[index]
            let location = Square(x, y)
            return canMove(piece, to: location)
        }
        return false
    }
    
    // MARK: - Mutating Instance Methods
    
    mutating func concede() {
        winner = (activePlayer == .player ? .opponent : .player)
    }
    
    mutating func select(_ piece: Piece) {
        if let index = pieces.firstIndex(matching: piece) {
            selectedPieceIndex = piece.isSelected ? nil : index
        }
    }
    
    mutating func deselectAllPieces() {
        selectedPieceIndex = nil
    }
    
    mutating func moveTo(_ x: Int, _ y: Int, newMove: Bool = true) {
        if selectedPieceIndex != nil, canMove(pieces[selectedPieceIndex!], to: Square(x, y)) {
            let newLocation = Square(x, y)
            let oldLocation = pieces[selectedPieceIndex!].location
            var move = Move(oldLocation: oldLocation, newLocation: newLocation)
            
            if let capturedPiece = pieceAt(newLocation), let capturedIndex = pieces.firstIndex(of: capturedPiece) {
                pieces.remove(at: capturedIndex)
                move.capturedPiece = true
            }
            
            moves.append(move)
            pieces[selectedPieceIndex!].location = newLocation
            selectedPieceIndex = nil
            activePlayer = opponent(for: activePlayer)
            winner = determineWinner()
        }
    }
    
    mutating func undo() {
        if let previousMove = moves.popLast() {
            let piece = pieceAt(previousMove.newLocation)!
            let index = pieces.firstIndex(matching: piece)!
            pieces[index].location = previousMove.oldLocation
            
            if previousMove.capturedPiece {
                pieces.append(Piece(player: activePlayer, location: previousMove.newLocation))
            }
            
            activePlayer = opponent(for: activePlayer)
        }
    }
    
    // MARK: - Private Instance Methods
    
    private func opponent(for player: Player) -> Player {
        player == .player ? .opponent : .player
    }
    
    private func canMove(_ piece: Piece, to location: Square) -> Bool {
        (canMoveHorizontally(piece, to: location) || canMoveVertically(piece, to: location) || canMoveDiagonally(piece, to: location))
            && validMove(piece, movingTo: location)
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
        piece.player == pieceAt(location)?.player
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
    
    private func determineWinner() -> Player? {
        if didWin(.player) {
            return .player
        } else if didWin(.opponent) {
            return .opponent
        }
        return nil
    }
    
    private func didWin(_ player: Player) -> Bool {
        let pieces = playerPieces(for: player)
        return pieces.count < 2 || allConnected(pieces)
    }
    
    private func allConnected(_ pieces: [Piece]) -> Bool {
        var connectedPieces = [pieces.first!]
        var shouldCheckForConnections = true
        
        while shouldCheckForConnections {
            shouldCheckForConnections = false
            
            outerLoop: for p1 in pieces.filter({ !connectedPieces.contains($0) }) {
                for p2 in connectedPieces {
                    if abs(p1.location.x - p2.location.x) <= 1 && abs(p1.location.y - p2.location.y) <= 1 {
                        shouldCheckForConnections = true
                        connectedPieces.append(p1)
                        break outerLoop
                    }
                }
            }
        }
        
        return connectedPieces.count == pieces.count
    }
        
    // MARK: - Objects
    
    struct Square: Equatable, Hashable {
        let x: Int
        let y: Int
        
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
    }
    
    struct Move {
        let oldLocation: Square
        let newLocation: Square
        var capturedPiece = false
    }
    
    struct Piece: Identifiable, Hashable {
        let id = UUID()
        let player: Player
        var location: Square
        var isSelected = false
    }
    
    enum Player: String {
        case player, opponent
    }
}
