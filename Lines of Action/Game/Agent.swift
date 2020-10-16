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
    
    init() {
        moveValues = Agent.computeMoveValues()
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
            return value(of: board, for: board.inactivePlayer, winner: winner)
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
    
    private func value(of board: GameBoard, for player: Player, winner: Player?) -> Double {
        if winner != nil {
            return winner == player ? .infinity : -.infinity
        }
        
        let pieces = board.pieces(for: player)
        
        // concentration
        let centerX = pieces.map { $0.location.x }.reduce(0, +) / pieces.count
        let centerY = pieces.map { $0.location.y }.reduce(0, +) / pieces.count
        let sumOfDistances = pieces.map { min(abs($0.location.x - centerX), abs($0.location.y - centerY)) }.reduce(0, +)
        let surplusOfDistances = sumOfDistances - Agent.minSumOfDistances[pieces.count]!
        let concentration = 1 / Double(max(1, surplusOfDistances))
        
        // mobility
        let mobility = computeSumOfMoveValues(for: board) / (16 * Double(pieces.count))
        
        // centralization
        let intLocations = pieces.map { $0.location.x + $0.location.y * board.size }
        let centralization = normalizeCentralization(intLocations.map { Agent.squareValues[$0] }.reduce(0, +),
                                                     pieceCount: pieces.count)
        
        // uniformity
        let xLocations = pieces.map { $0.location.x }.sorted()
        let yLocations = pieces.map { $0.location.y }.sorted()
        let uniformity = 64.0 / Double((xLocations.last! - xLocations.first!) * (yLocations.last! - yLocations.first!))
        
        // connectedness
        var connections: Double = 0
        for p1 in pieces {
            for p2 in pieces {
                if abs(p1.location.x - p2.location.x) <= 1 && abs(p1.location.y - p2.location.y) <= 1 {
                    connections += 1
                }
            }
        }
        let connectedness = connections / Double(pieces.count)
        
        // to move
        let isMoving: Double = player == board.activePlayer ? 1 : 0
        
        // heuristic evaluation
        let playerHeuristic =
            40 * concentration +
            30 * mobility +
            15 * centralization +
            9 * uniformity +
            5 * connectedness +
            1 * isMoving
        let opponentHeuristic = player == board.activePlayer
            ? 0 : value(of: board, for: board.activePlayer, winner: winner)
        return playerHeuristic - opponentHeuristic
    }
    
    private func normalizeCentralization(_ value: Double, pieceCount: Int) -> Double {
        let minSquareValues = Double(pieceCount) * Agent.squareValues.min()!
        let maxSquareValues = Double(pieceCount) * Agent.squareValues.max()!
        return (value - minSquareValues) / (maxSquareValues - minSquareValues)
    }
    
    private func computeSumOfMoveValues(for board: GameBoard) -> Double {
        var sumOfMoveValues: Double = 0
        
        for move in board.generateMoves() {
            let fromIndex = move.piece.location.x + 8 * move.piece.location.y
            let toIndex = move.newLocation.x + 8 * move.newLocation.y
            sumOfMoveValues += moveValues[fromIndex]![toIndex]! * (board.pieceAt(move.newLocation) != nil ? 2 : 1)
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
    
    private static func computeMoveValues() -> [Int : [Int : Double]] {
        var edges: [Int] = []
        for i in 0..<8 {
            edges += [i, 56 + i, i * 8, i * 8 + 7]
        }
        edges = Array(Set(edges))
        
        var moveValues = [Int : [Int : Double]]()
        for i in 0..<64 {
            var cellValues = [Int : Double]()

            for j in 0..<64 {
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
