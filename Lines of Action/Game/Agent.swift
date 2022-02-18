//
//  Agent.swift
//  Lines of Action
//
//  Created by David Crow on 10/15/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

struct Agent {
    private typealias Piece = GameBoard.Piece
    private typealias Square = GameBoard.Square
    private typealias Player = LinesOfAction.Player
    
    private var bestMove: Move?
    private var moveValues: [Int : [Int : Double]]
    
    init(boardSize: Int) {
        moveValues = Agent.computeMoveValues(for: boardSize)
    }
    
    mutating func move(board: GameBoard) -> Move? {
        bestMove = nil
        minimax(board, isRoot: true)
        return bestMove
    }
    
    @discardableResult private mutating func minimax(_ board: GameBoard, depth: Int = Agent.maxDepth,
                                                     alpha: Double = -.infinity, beta: Double = .infinity,
                                                     isMax: Bool = true, isRoot: Bool = false) -> Double
    {
        let winner = board.determineWinner()
        if winner != nil || depth == 0 {
            return value(of: board, for: board.inactivePlayer, at: depth, winner: winner)
        }
        
        var value: Double
        
        if isMax {
            value = -.infinity
            var alpha = alpha
            
            for move in board.generateMoves() {
                var nextBoard = board
                nextBoard.move(move.piece, to: move.newLocation)
                value = max(value, minimax(nextBoard, depth: depth - 1, alpha: alpha, beta: beta, isMax: false))
                alpha = max(alpha, value)
                
                if isRoot && (bestMove == nil || value > bestMove!.value) {
                    bestMove = Move(other: move, value: value)
                }
                
                if alpha >= beta {
                    break
                }
            }
        } else {
            value = .infinity
            var beta = beta
            
            for move in board.generateMoves() {
                var nextBoard = board
                nextBoard.move(move.piece, to: move.newLocation)
                value = min(value, minimax(nextBoard, depth: depth - 1, alpha: alpha, beta: beta, isMax: true))
                beta = min(beta, value)
                
                if beta <= alpha {
                    break
                }
            }
        }
        
        return value
    }
    
    // MARK: - State Evaluation
    
    private func value(of board: GameBoard, for player: Player, at depth: Int, winner: Player?) -> Double {
        if winner != nil {
            return (winner == player ? .infinity : -.infinity) / Double(depth + 1)
        }
        
        let pieces = board.pieces(for: player)
        let pieceCount = pieces.count
        
        // concentration
        let centerX = pieces.map { $0.location.x }.reduce(0, +) / pieceCount
        let centerY = pieces.map { $0.location.y }.reduce(0, +) / pieceCount
        let sumOfDistances = pieces.map { max(abs($0.location.x - centerX), abs($0.location.y - centerY)) }.reduce(0, +)
        let surplusOfDistances = sumOfDistances - Agent.minSumOfDistances[pieceCount]!
        let concentration = 1 / Double(max(1, surplusOfDistances))
        
        // mobility
        let mobility = computeSumOfMoveValues(for: board) / Double(16 * pieceCount)
        
        // quads
        var strongQuadCount: Int = 0
        if board.size > 5 {
            let middleIndex: Int = board.size / 2
            
            for i in -2...2 {
                for j in -2...2 {
                    let quadValue = board.quadValues[player.rawValue][middleIndex + i][middleIndex + j]
                    if quadValue == 3 || quadValue == 4 {
                        strongQuadCount += 1
                    }
                }
            }
        } else {
            strongQuadCount = board.quadCounts[player.rawValue][3] + board.quadCounts[player.rawValue][4]
        }
        let quads = Double(strongQuadCount) / Double(Agent.maxStrongQuadCount[pieceCount]!)
        
        // centralization
        let intLocations = pieces.map { $0.location.x + $0.location.y * board.size }
        let centralization = computeCentralization(for: intLocations)
        
        // uniformity
        let xLocations = pieces.map { $0.location.x }
        let yLocations = pieces.map { $0.location.y }
        let area = (1 + xLocations.max()! - xLocations.min()!) * (1 + yLocations.max()! - yLocations.min()!)
        let uniformity = 1.0 / Double(area)
        
        // connectedness
        var connections: Double = 0
        for p1 in pieces {
            for p2 in pieces {
                if abs(p1.location.x - p2.location.x) <= 1 && abs(p1.location.y - p2.location.y) <= 1 {
                    connections += 1
                }
            }
        }
        connections -= Double(pieceCount)
        let connectedness = connections / Agent.maxConnections[pieceCount]!
        
        // MARK: - todo: walls
        
        // MARK: - todo: center of mass
        
        // is moving
        let isMoving: Double = player == board.activePlayer ? 1 : 0
        
        // heuristic evaluation
        let playerHeuristic =
            30 * concentration +
            25 * mobility +
            15 * quads +
            11 * centralization +
            5 * uniformity +
            5 * connectedness +
            5 * walls +
            3 * centerOfMass +
            1 * isMoving
        let opponentHeuristic = player == board.activePlayer
            ? 0 : value(of: board, for: board.activePlayer, at: depth, winner: winner)
        return playerHeuristic - opponentHeuristic
    }
    
    private func computeCentralization(for intLocations: [Int]) -> Double {
        let pieceCount = intLocations.count
        let value = intLocations.map { Agent.squareValues[$0] }.reduce(0, +)
        let minValue = Double(pieceCount) * Agent.squareValues.min()!
        let maxValue = Double(pieceCount) * Agent.squareValues.max()!
        return (value - minValue) / (maxValue - minValue)
    }
    
    private func computeSumOfMoveValues(for board: GameBoard) -> Double {
        var sumOfMoveValues: Double = 0
        
        for move in board.generateMoves() {
            let fromIndex = move.piece.location.x + board.size * move.piece.location.y
            let toIndex = move.newLocation.x + board.size * move.newLocation.y
            sumOfMoveValues += moveValues[fromIndex]![toIndex]! * (move.capturedPiece ? 2 : 1)
        }
        
        return sumOfMoveValues
    }
    
    // MARK: - Type Properties/Methods
    
    private static let maxDepth: Int = 1
    
    private static let minSumOfDistances: [Int : Int] = [
        1: 0,
        2: 1,
        3: 2,
        4: 3,
        5: 4,
        6: 5,
        7: 6,
        8: 7,
        9: 8,
        10: 10,
        11: 12,
        12: 14
    ]
    
    private static let maxStrongQuadCount: [Int : Int] = [
        0: 0,
        1: 0,
        2: 0,
        3: 1,
        4: 2,
        5: 4,
        6: 4,
        7: 5,
        8: 6,
        9: 8,
        10: 8,
        11: 9,
        12: 10
    ]
    
    private static let squareValues: [Double] = [
        -80, -25, -20, -20, -20, -20, -25, -80,
        -25,  10,  10,  10,  10,  10,  10, -25,
        -20,  10,  25,  25,  25,  25,  10, -20,
        -20,  10,  25,  50,  50,  25,  10, -20,
        -20,  10,  25,  50,  50,  25,  10, -20,
        -20,  10,  25,  25,  25,  25,  10, -20,
        -25,  10,  10,  10,  10,  10,  10, -25,
        -80, -25, -20, -20, -20, -20, -25, -80
    ]
    
    private static let maxConnections: [Int : Double] = [
        1: 0,
        2: 2,
        3: 6,
        4: 12,
        5: 16,
        6: 22,
        7: 28,
        8: 34,
        9: 40,
        10: 46,
        11: 52,
        12: 58
    ]
    
    private static func computeMoveValues(for size: Int) -> [Int : [Int : Double]] {
        let lastIndex = size - 1
        var edges: [Int] = []
        var moveValues = [Int : [Int : Double]]()
        
        for i in 0..<size {
            edges += [i, i + (size * lastIndex), i * size, i * size + lastIndex]
        }
        edges = Array(Set(edges))
        
        for i in 0 ..< size * size {
            var cellValues = [Int : Double]()

            for j in 0 ..< size * size {
                if edges.contains(j) {
                    cellValues[j] = edges.contains(i) ? 0.25 : 0.5
                } else {
                    cellValues[j] = 1
                }
            }
            
            moveValues[i] = cellValues
        }
        
        return moveValues
    }
}
