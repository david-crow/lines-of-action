//
//  GameBoard.swift
//  Lines of Action
//
//  Created by David Crow on 10/15/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

struct GameBoard {
    // MARK: - Variables
    
    let size: Int
    private let lastIndex: Int
    
    var pieces: [Piece]
    private var squares: [[Player]]
    private var verticalCount: [Int]
    private var horizontalCount: [Int]
    private var posDiagonalCount: [Int]
    private var negDiagonalCount: [Int]
    
    private(set) var activePlayer: Player = .player
    var inactivePlayer: Player {
        activePlayer == .player ? .opponent : .player
    }
    
    // MARK: - Initializers
    
    init(size: Int) {
        self.size = size
        self.lastIndex = size - 1
        self.pieces = []
        self.squares = [[Player]](repeating: [Player](repeating: .none, count: size), count: size)
        self.verticalCount = Array(repeating: 0, count: size)
        self.horizontalCount = Array(repeating: 0, count: size)
        self.posDiagonalCount = Array(repeating: 0, count: size + lastIndex)
        self.negDiagonalCount = Array(repeating: 0, count: size + lastIndex)
        
        for i in 1..<lastIndex {
            self.squares[i][0] = .player
            self.squares[i][lastIndex] = .player
            self.squares[0][i] = .opponent
            self.squares[lastIndex][i] = .opponent
            
            self.pieces.append(Piece(player: .player, location: Square(i, 0)))
            self.pieces.append(Piece(player: .player, location: Square(i, lastIndex)))
            self.pieces.append(Piece(player: .opponent, location: Square(0, i)))
            self.pieces.append(Piece(player: .opponent, location: Square(lastIndex, i)))
            
            self.verticalCount[i] = 2
            self.horizontalCount[i] = 2
            self.posDiagonalCount[i] = 2
            self.posDiagonalCount[i + lastIndex] = 2
            self.negDiagonalCount[i] = 2
            self.negDiagonalCount[i + lastIndex] = 2
        }
        
        verticalCount[0] = size - 2
        verticalCount[lastIndex] = size - 2
        horizontalCount[0] = size - 2
        horizontalCount[lastIndex] = size - 2
        posDiagonalCount[0] = 0
        posDiagonalCount[lastIndex] = 0
        posDiagonalCount[lastIndex * 2] = 0
        posDiagonalCount[0] = 0
        posDiagonalCount[lastIndex] = 0
        posDiagonalCount[lastIndex * 2] = 0
    }
    
    // MARK: - Accessors
    
    func opponent(of player: Player) -> Player {
        player == .player ? .opponent : .player
    }
    
    func determineWinner() -> Player? {
        if didWin(inactivePlayer) {
            return inactivePlayer
        } else if didWin(activePlayer) {
            return activePlayer
        }
        return nil
    }
    
    func pieces(for player: Player) -> [Piece] {
        pieces.filter { $0.player == player }
    }
    
    func pieceAt(_ location: Square) -> Piece? {
        for piece in pieces {
            if piece.location.x == location.x && piece.location.y == location.y {
                return piece
            }
        }
        return nil
    }
    
    func generateMoves() -> [Move] {
        var moves: [Move] = []
        for piece in pieces(for: activePlayer) {
            moves += findDestinations(for: piece).map { Move(piece, to: $0) }
        }
        return moves
    }
    
    func findDestinations(for piece: Piece) -> [Square] {
        var destinations: [Square] = []
        let x = piece.location.x
        let y = piece.location.y
        
        var distance = verticalCount[x]
        if y - distance >= 0 && squares[x][y - distance] != activePlayer {
            destinations += canMove(from: piece.location, distance: distance, xDirection: 0, yDirection: -1)
        }
        if y + distance < size && squares[x][y + distance] != activePlayer {
            destinations += canMove(from: piece.location, distance: distance, xDirection: 0, yDirection: 1)
        }
        
        distance = horizontalCount[y]
        if x - distance >= 0 && squares[x - distance][y] != activePlayer {
            destinations += canMove(from: piece.location, distance: distance, xDirection: -1, yDirection: 0)
        }
        if x + distance < size && squares[x + distance][y] != activePlayer {
            destinations += canMove(from: piece.location, distance: distance, xDirection: 1, yDirection: 0)
        }
        
        distance = posDiagonalCount[x + y]
        if x + distance < size && y - distance >= 0 && squares[x + distance][y - distance] != activePlayer {
            destinations += canMove(from: piece.location, distance: distance, xDirection: 1, yDirection: -1)
        }
        if x - distance >= 0 && y + distance < size && squares[x - distance][y + distance] != activePlayer {
            destinations += canMove(from: piece.location, distance: distance, xDirection: -1, yDirection: 1)
        }
        
        distance = negDiagonalCount[x + lastIndex - y]
        if x - distance >= 0 && y - distance >= 0 && squares[x - distance][y - distance] != activePlayer {
            destinations += canMove(from: piece.location, distance: distance, xDirection: -1, yDirection: -1)
        }
        if x + distance < size && y + distance < size && squares[x + distance][y + distance] != activePlayer {
            destinations += canMove(from: piece.location, distance: distance, xDirection: 1, yDirection: 1)
        }
        
        return destinations
    }
    
    // MARK: - Mutators
    
    @discardableResult mutating func move(_ piece: Piece, to newLocation: Square) -> Move {
        var move = Move(piece, to: newLocation)
        
        if let capturedPiece = pieceAt(newLocation), let capturedIndex = pieces.firstIndex(of: capturedPiece) {
            move.capturedPiece = true
            pieces.remove(at: capturedIndex)
        } else {
            addLines(for: move.newLocation)
        }
        
        let index = pieces.firstIndex(matching: piece)!
        pieces[index].location = newLocation
        squares[piece.location.x][piece.location.y] = .none
        squares[newLocation.x][newLocation.y] = piece.player
        subtractLines(for: move.oldLocation)
        switchPlayers()
        
        return move
    }
    
    mutating func undo(_ move: Move) {
        let piece = pieceAt(move.newLocation)!
        let index = pieces.firstIndex(matching: piece)!
        pieces[index].location = move.oldLocation
        squares[move.oldLocation.x][move.oldLocation.y] = piece.player
        addLines(for: move.oldLocation)
        
        if move.capturedPiece {
            pieces.append(Piece(player: opponent(of: piece.player), location: move.newLocation))
            squares[move.newLocation.x][move.newLocation.y] = opponent(of: piece.player)
        } else {
            subtractLines(for: move.newLocation)
            squares[move.newLocation.x][move.newLocation.y] = .none
        }
        
        switchPlayers()
    }
    
    mutating func redo(_ move: Move) {
        if move.capturedPiece {
            let capturedPiece = pieceAt(move.newLocation)!
            let capturedIndex = pieces.firstIndex(matching: capturedPiece)!
            pieces.remove(at: capturedIndex)
        } else {
            addLines(for: move.newLocation)
        }
        
        let index = pieces.firstIndex(matching: pieceAt(move.oldLocation)!)!
        pieces[index].location = move.newLocation
        squares[move.oldLocation.x][move.oldLocation.y] = .none
        squares[move.newLocation.x][move.newLocation.y] = move.piece.player
        subtractLines(for: move.oldLocation)
        switchPlayers()
    }
    
    // MARK: - Helpers
    
    private func didWin(_ player: Player) -> Bool {
        let pieces = self.pieces(for: player)
        return pieces.count < 2 || allConnected(pieces)
    }
    
    private func allConnected(_ pieces: [Piece]) -> Bool {
        // TODO: - implement quads, check Euler > 1
        
        var connectedPieces = [pieces.first!]
        var remainingPieces = pieces[1...]
        var shouldCheckForConnections = true
        
        while shouldCheckForConnections {
            shouldCheckForConnections = false
            
            outerLoop: for p1 in remainingPieces {
                for p2 in connectedPieces {
                    if abs(p1.location.x - p2.location.x) <= 1 && abs(p1.location.y - p2.location.y) <= 1 {
                        shouldCheckForConnections = true
                        connectedPieces.append(p1)
                        remainingPieces.remove(at: remainingPieces.firstIndex(of: p1)!)
                        break outerLoop
                    }
                }
            }
        }
        
        return connectedPieces.count == pieces.count
    }
    
    private func canMove(from location: Square, distance: Int, xDirection: Int, yDirection: Int) -> [Square] {
        for i in 1..<distance {
            if squares[location.x + i * xDirection][location.y + i * yDirection] == inactivePlayer {
                return []
            }
        }
        return [Square(location.x + distance * xDirection, location.y + distance * yDirection)]
    }
    
    private mutating func switchPlayers() {
        activePlayer = opponent(of: activePlayer)
    }
    
    private mutating func addLines(for location: Square) {
        updateLines(for: location, adding: 1)
    }
    
    private mutating func subtractLines(for location: Square) {
        updateLines(for: location, adding: -1)
    }
    
    private mutating func updateLines(for location: Square, adding value: Int) {
        horizontalCount[location.y] += value
        verticalCount[location.x] += value
        posDiagonalCount[location.x + location.y] += value
        negDiagonalCount[location.x - location.y + lastIndex] += value
    }
    
    // MARK: - Objects
    
    enum Player {
        case none, player, opponent
    }
    
    struct Piece: Identifiable, Hashable {
        let id = UUID()
        let player: Player
        var location: Square
        var isSelected = false
    }
    
    struct Square: Equatable, Hashable {
        let x: Int
        let y: Int
        
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
    }
}
