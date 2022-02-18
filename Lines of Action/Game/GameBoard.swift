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
    private(set) var quadValues: [[[Int]]]
    private(set) var quadCounts: [[Int]]
    
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
        self.quadValues = [[[Int]]](repeating: [[Int]](repeating: [Int](repeating: 0, count: size + 1), count: size + 1), count: 2)
        self.quadCounts = [[Int]](repeating: [Int](repeating: 0, count: 6), count: 2)
        
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
        
        countQuads()
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
        let player = piece.player
        var move = Move(piece, to: newLocation)
        
        // update the quad counts pre-move
        decrementQuadCounts(for: player, at: move.oldLocation)
        decrementQuadCounts(for: player, at: move.newLocation)
        
        // maintain accurate quad counts in the event that the piece only moves one square orthogonally
        // and save the occupied locations in the quad
        let quadLocations = computeQuadLocations(for: player, making: move)
        
        // update the occupied squares and the lines of action
        squares[piece.location.x][piece.location.y] = .none
        squares[newLocation.x][newLocation.y] = piece.player
        subtractLines(for: move.oldLocation)
        
        // update the quads for the moving piece
        removeQuad(for: player, at: move.oldLocation)
        addQuad(for: player, at: move.newLocation)
        
        // if the move captures a piece...
        if let capturedPiece = pieceAt(move.newLocation), let capturedIndex = pieces.firstIndex(of: capturedPiece) {
            move.capturedPiece = true
            pieces.remove(at: capturedIndex)
            
            // update the quads and quad counts for the captured piece
            decrementQuadCounts(for: opponent(of: player), at: move.newLocation)
            removeQuad(for: opponent(of: player), at: move.newLocation)
            incrementQuadCounts(for: opponent(of: player), at: move.newLocation)
        } else {
            addLines(for: move.newLocation)
        }

        // update the quad counts post-move
        incrementQuadCounts(for: player, at: move.oldLocation)
        incrementQuadCounts(for: player, at: move.newLocation)

        for location in quadLocations {
            quadCounts[player.rawValue][quadValues[player.rawValue][location.x][location.y]] -= 1
        }
        
        // find and move the piece
        let index = pieces.firstIndex(matching: piece)!
        pieces[index].location = newLocation
        switchPlayers()
        
        return move
    }
    
    mutating func undo(_ move: Move) {
        let player = move.piece.player
        
        // find and move the piece
        let piece = pieceAt(move.newLocation)!
        let index = pieces.firstIndex(matching: piece)!
        pieces[index].location = move.oldLocation
        
        // update the occupied squares and the lines of action
        squares[move.oldLocation.x][move.oldLocation.y] = player
        squares[move.newLocation.x][move.newLocation.y] = move.capturedPiece ? opponent(of: player) : .none
        addLines(for: move.oldLocation)
        
        // maintain accurate quad counts in the event that the piece only moves one square orthogonally
        // and save the occupied locations in the quad
        let quadLocations = computeQuadLocations(for: player, making: move)
        
        // update the quad counts pre-move
        decrementQuadCounts(for: player, at: move.oldLocation)
        decrementQuadCounts(for: player, at: move.newLocation)
        
        // update the quads for the moving piece
        removeQuad(for: player, at: move.newLocation)
        addQuad(for: player, at: move.oldLocation)
        
        // if the move captured a piece...
        if move.capturedPiece {
            pieces.append(Piece(player: opponent(of: piece.player), location: move.newLocation))
            
            // update the quads and quad counts for the captured piece
            decrementQuadCounts(for: opponent(of: player), at: move.newLocation)
            addQuad(for: opponent(of: player), at: move.newLocation)
            incrementQuadCounts(for: opponent(of: player), at: move.newLocation)
        } else {
            subtractLines(for: move.newLocation)
            squares[move.newLocation.x][move.newLocation.y] = .none
        }
        
        // update the quad counts post-move
        incrementQuadCounts(for: player, at: move.newLocation)
        incrementQuadCounts(for: player, at: move.oldLocation)
        
        for location in quadLocations {
            quadCounts[player.rawValue][quadValues[player.rawValue][location.x][location.y]] -= 1
        }
        
        switchPlayers()
    }
    
    mutating func stepBackward(to move: Move) {
        let index = pieces.firstIndex(matching: pieceAt(move.newLocation)!)!
        pieces[index].location = move.oldLocation
        switchPlayers()
        
        if move.capturedPiece {
            pieces.append(Piece(player: opponent(of: move.piece.player), location: move.newLocation))
        }
    }
    
    mutating func stepForward(to move: Move) {
        if move.capturedPiece {
            let capturedPiece = pieceAt(move.newLocation)!
            let capturedIndex = pieces.firstIndex(matching: capturedPiece)!
            pieces.remove(at: capturedIndex)
        }
        
        let index = pieces.firstIndex(matching: pieceAt(move.oldLocation)!)!
        pieces[index].location = move.newLocation
        switchPlayers()
    }
    
    // MARK: - Helpers
    
    private func didWin(_ player: Player) -> Bool {
        let pieces = self.pieces(for: player)
        return pieces.count < 2 || allConnected(pieces, for: player)
    }
    
    private func allConnected(_ pieces: [Piece], for player: Player) -> Bool {
        let side = player.rawValue
        let euler = Double(quadCounts[side][1] - quadCounts[side][3] - 2 * quadCounts[side][5]) / 4
        if euler > 1 {
            return false
        }
        
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
    
    private func owned(by player: Player, at location: Square) -> Bool {
        if location.x < 0 || location.y < 0 || location.x >= size || location.y >= size {
            return false
        }
        
        return player == playerAt(location)
    }
    
    private func playerAt(_ location: Square) -> Player {
        squares[location.x][location.y]
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
    
    private mutating func countQuads() {
        quadCounts = [[Int]](repeating: [Int](repeating: 0, count: 6), count: 2)
        
        for i in 0 ..< size + 1 {
            for j in 0 ..< size + 1 {
                quadValues[Player.player.rawValue][i][j] = quadValue(for: .player, at: Square(i, j))
                quadValues[Player.opponent.rawValue][i][j] = quadValue(for: .opponent, at: Square(i, j))
                quadCounts[Player.player.rawValue][quadValues[Player.player.rawValue][i][j]] += 1
                quadCounts[Player.opponent.rawValue][quadValues[Player.opponent.rawValue][i][j]] += 1
            }
        }
    }
    
    private func quadValue(for player: Player, at location: Square) -> Int {
        let x = location.x
        let y = location.y
        
        let possibleLocations = [Square(x - 1, y - 1), Square(x, y - 1), Square(x - 1, y), Square(x, y)]
        let actualLocations = possibleLocations.map { owned(by: player, at: $0) }
        let count = actualLocations.map { $0.intValue }.reduce(0, +)
        
        // diagonal
        if count == 2 && ((actualLocations[0] && actualLocations[3]) || (actualLocations[1] && actualLocations[2]))
        {
            return 5
        }
        
        return count
    }
    
    private mutating func addQuad(for player: Player, at location: Square) {
        let side = player.rawValue
        let x = location.x
        let y = location.y
        
        quadValues[side][x + 1][y + 1] = incrementedQuadValue(for: player, at: Square(x, y), currentValue: quadValues[side][x + 1][y + 1])
        quadValues[side][x + 1][y] = incrementedQuadValue(for: player, at: Square(x, y - 1), currentValue: quadValues[side][x + 1][y])
        quadValues[side][x][y + 1] = incrementedQuadValue(for: player, at: Square(x - 1, y), currentValue: quadValues[side][x][y + 1])
        quadValues[side][x][y] = incrementedQuadValue(for: player, at: Square(x - 1, y - 1), currentValue: quadValues[side][x][y])
    }
    
    private mutating func removeQuad(for player: Player, at location: Square) {
        let side = player.rawValue
        let x = location.x
        let y = location.y
        
        quadValues[side][x + 1][y + 1] = decrementedQuadValue(for: player, at: Square(x, y), currentValue: quadValues[side][x + 1][y + 1])
        quadValues[side][x + 1][y] = decrementedQuadValue(for: player, at: Square(x, y - 1), currentValue: quadValues[side][x + 1][y])
        quadValues[side][x][y + 1] = decrementedQuadValue(for: player, at: Square(x - 1, y), currentValue: quadValues[side][x][y + 1])
        quadValues[side][x][y] = decrementedQuadValue(for: player, at: Square(x - 1, y - 1), currentValue: quadValues[side][x][y])
    }
    
    private func incrementedQuadValue(for player: Player, at location: Square, currentValue: Int) -> Int {
        let newValue = currentValue + 1
        
        if newValue == 6 {
            return 3
        }
        
        if quadIsDiagonal(for: player, at: location, quadValue: newValue) {
            return 5
        }
        
        return newValue
    }
    
    private func decrementedQuadValue(for player: Player, at location: Square, currentValue: Int) -> Int {
        let newValue = currentValue - 1
        
        if newValue == 4 {
            return 1
        }
        
        if quadIsDiagonal(for: player, at: location, quadValue: newValue) {
            return 5
        }
        
        return newValue
    }
    
    private func quadIsDiagonal(for player: Player, at location: Square, quadValue: Int) -> Bool {
        let x = location.x
        let y = location.y
        
        return quadValue == 2 && x >= 0 && y >= 0 && x < lastIndex && y < lastIndex
            && ((squares[x][y] == player && squares[x + 1][y + 1] == player)
                    || (squares[x + 1][y] == player && squares[x][y + 1] == player))
    }
    
    private mutating func incrementQuadCounts(for player: Player, at location: Square) {
        updateQuadCounts(for: player, at: location, adding: 1)
    }
    
    private mutating func decrementQuadCounts(for player: Player, at location: Square) {
        updateQuadCounts(for: player, at: location, adding: -1)
    }

    private mutating func updateQuadCounts(for player: Player, at location: Square, adding value: Int) {
        quadCounts[player.rawValue][quadValues[player.rawValue][location.x + 1][location.y + 1]] += value
        quadCounts[player.rawValue][quadValues[player.rawValue][location.x + 1][location.y]] += value
        quadCounts[player.rawValue][quadValues[player.rawValue][location.x][location.y + 1]] += value
        quadCounts[player.rawValue][quadValues[player.rawValue][location.x][location.y]] += value
    }
    
    private mutating func computeQuadLocations(for player: Player, making move: Move) -> [Square] {
        var quadLocations: [Square] = []

        if abs(move.newLocation.x - move.oldLocation.x) == 1 && move.newLocation.y == move.oldLocation.y {
            let maxRow = max(move.oldLocation.x, move.newLocation.x)
            quadLocations = [Square(maxRow, move.oldLocation.y), Square(maxRow, move.oldLocation.y + 1)]
        } else if move.newLocation.x == move.oldLocation.x && abs(move.newLocation.y - move.oldLocation.y) == 1 {
            let maxCol = max(move.oldLocation.y, move.newLocation.y)
            quadLocations = [Square(move.oldLocation.x, maxCol), Square(move.oldLocation.x + 1, maxCol)]
        }

        for location in quadLocations {
            quadCounts[player.rawValue][quadValues[player.rawValue][location.x][location.y]] += 1
        }

        return quadLocations
    }
    
    // MARK: - Objects
    
    enum Player: Int {
        case none = -1, player = 0, opponent = 1
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
