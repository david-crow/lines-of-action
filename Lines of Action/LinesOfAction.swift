//
//  LinesOfAction.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

// MARK: - Lines of Action

class LinesOfAction: ObservableObject {
    typealias Player = GameBoard.Player
    typealias Piece = GameBoard.Piece
    typealias Square = GameBoard.Square
    
    // MARK: - Variables
    
    let gameType: GameType
    private var agent: Agent?
    
    @Published private(set) var gameMode: GameMode = .playing
    @Published private(set) var board: GameBoard
    @Published private(set) var winner: Player? {
        didSet {
            if winner != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [self] in
                    gameMode = .gameOver
                })
            }
        }
    }
    
    private var moveCounter: Int = -1
    private var moves: [Move] = []
    private var destinations: [Square] = []
    
    private var selectedPieceIndex: Int? {
        get { board.pieces.indices.filter { board.pieces[$0].isSelected }.only }
        set {
            for index in board.pieces.indices {
                board.pieces[index].isSelected = index == newValue
            }
            
            if newValue == nil {
                destinations = []
            }
        }
    }

    // MARK: - Initializers
    
    init(gameType: GameType, boardSize: Int = 8) {
        self.gameType = gameType
        self.board = GameBoard.createBoard(size: boardSize)
        self.agent = gameType == .offline ? nil : Agent()
    }
    
    // MARK: - Public Accessors
    
    var boardSize: Int {
        board.size
    }
    
    var piecesHaveBeenMoved: Bool {
        moves.count > 0
    }
    
    var inFinalState: Bool {
        moveCounter == moves.count - 1
    }
    
    var canStepBackward: Bool {
        moveCounter >= 0
    }
    
    var canStepForward: Bool {
        moveCounter < moves.count - 1
    }
    
    func isActive(_ player: Player) -> Bool {
        player == board.activePlayer
    }
    
    func isSelected(_ square: Square) -> Bool {
        if let index = selectedPieceIndex {
            return board.pieces[index] == board.pieceAt(square)
        }
        return false
    }
    
    func isPreviousMove(_ square: Square) -> Bool {
        if let previousMove = moves.last {
            return square == previousMove.oldLocation || square == previousMove.newLocation
        }
        return false
    }
    
    func canMoveTo(_ square: Square) -> Bool {
        destinations.contains(square)
    }
    
    // MARK: - Public Mutators
    
    func concede() {
        winner = board.inactivePlayer
    }
    
    func analyze() {
        gameMode = .analysis
    }
    
    func select(_ square: Square) {
        if let tappedPiece = board.pieceAt(square), tappedPiece.player == board.activePlayer {
            select(tappedPiece)
        } else if destinations.contains(square) {
            move(to: square)
        } else {
            selectedPieceIndex = nil
        }
    }
    
    func undo() {
        let undoCount = (gameType == .solo && winner == nil) ? 2 : 1
        for _ in 0..<undoCount {
            if let previousMove = moves.popLast() {
                board.undo(move: previousMove)
                moveCounter -= 1
            }
        }
    }
    
    func stepBackward() {
        if moveCounter >= 0 {
            board.stepBackward(to: moves[moveCounter])
            moveCounter -= 1
        }
    }
    
    func stepForward() {
        if moveCounter < moves.count - 1 {
            board.stepForward(to: moves[moveCounter + 1])
            moveCounter += 1
        }
    }
    
    // MARK: - Helpers
    
    private func select(_ piece: Piece) {
        if let index = board.pieces.firstIndex(matching: piece) {
            if piece.isSelected {
                selectedPieceIndex = nil
            } else {
                selectedPieceIndex = index
                destinations = board.findDestinations(for: piece)
            }
        }
    }
    
    private func move(to newLocation: Square) {
        moveHelper(newLocation: newLocation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
            if gameType == .solo && winner == nil {
                if let move = agent!.move(board: board) {
                    selectedPieceIndex = board.pieces.firstIndex(matching: move.piece)
                    moveHelper(newLocation: move.destination)
                } else {
                    winner = board.inactivePlayer
                }
            }
        })
    }
    
    private func moveHelper(newLocation: Square) {
        let move = board.move(board.pieces[selectedPieceIndex!], to: newLocation)
        moves.append(move)
        moveCounter += 1
        selectedPieceIndex = nil
        winner = board.determineWinner()
    }
    
    // MARK: - Objects
    
    enum GameType: String {
        case solo = "Single Player",
             offline = "Offline Multiplayer",
             online = "Online Multiplayer"
    }
    
    enum GameMode {
        case playing, gameOver, analysis
    }
    
    fileprivate struct Move {
        let oldLocation: Square
        let newLocation: Square
        var capturedPiece = false
    }
}

// MARK: - GameBoard

struct GameBoard {
    fileprivate typealias Move = LinesOfAction.Move
    
    // MARK: - Variables
    
    let size: Int
    
    fileprivate(set) var pieces: [Piece]
    fileprivate var squares: [Square]
    fileprivate var activePlayer: Player = .player
    
    fileprivate var inactivePlayer: Player {
        activePlayer == .player ? .opponent : .player
    }
    
    // MARK: - Type Methods
    
    fileprivate static func createBoard(size: Int) -> GameBoard {
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
        
        return GameBoard(size: size, pieces: pieces, squares: squares)
    }
    
    // MARK: - Accessors
    
    private func opponent(of player: Player) -> Player {
        player == .player ? .opponent : .player
    }
    
    fileprivate func determineWinner() -> Player? {
        if didWin(.player) {
            return .player
        } else if didWin(.opponent) {
            return .opponent
        }
        return nil
    }
    
    fileprivate func didWin(_ player: Player) -> Bool {
        let pieces = self.pieces(for: player)
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
    
    fileprivate func pieces(for player: Player) -> [Piece] {
        pieces.filter { $0.player == player }
    }
    
    fileprivate func pieceAt(_ location: Square) -> Piece? {
        for piece in pieces {
            if piece.location.x == location.x && piece.location.y == location.y {
                return piece
            }
        }
        return nil
    }
    
    fileprivate func isEdge(_ location: Square) -> Bool {
        location.x == 0 || location.x == size - 1 || location.y == 0 || location.y == size - 1
    }
    
    fileprivate func generateMoves() -> [Agent.Move] {
        var moves: [Agent.Move] = []
        for piece in pieces(for: activePlayer) {
            moves += findDestinations(for: piece).map { Agent.Move(piece, to: $0) }
        }
        return moves
    }
    
    fileprivate func findDestinations(for piece: Piece) -> [Square] {
        squares.filter { canMove(piece, to: $0) }
    }
    
    // MARK: - Mutators
    
    private mutating func switchPlayers() {
        activePlayer = opponent(of: activePlayer)
    }
    
    @discardableResult fileprivate mutating func move(_ piece: Piece, to newLocation: Square) -> Move {
        let oldLocation = piece.location
        var move = Move(oldLocation: oldLocation, newLocation: newLocation)
        
        if let capturedPiece = pieceAt(newLocation), let capturedIndex = pieces.firstIndex(of: capturedPiece) {
            pieces.remove(at: capturedIndex)
            move.capturedPiece = true
        }
        
        let index = pieces.firstIndex(matching: piece)!
        pieces[index].location = newLocation
        switchPlayers()
        
        return move
    }
    
    fileprivate mutating func undo(move previousMove: Move) {
        let piece = pieceAt(previousMove.newLocation)!
        let index = pieces.firstIndex(matching: piece)!
        pieces[index].location = previousMove.oldLocation
        
        if previousMove.capturedPiece {
            pieces.append(Piece(player: opponent(of: piece.player), location: previousMove.newLocation))
        }
        
        switchPlayers()
    }
    
    fileprivate mutating func stepBackward(to move: Move) {
        let piece = pieceAt(move.newLocation)!
        let index = pieces.firstIndex(matching: piece)!
        pieces[index].location = move.oldLocation
        
        if move.capturedPiece {
            pieces.append(Piece(player: opponent(of: piece.player), location: move.newLocation))
        }
        
        switchPlayers()
    }
    
    fileprivate mutating func stepForward(to move: Move) {
        if move.capturedPiece {
            let capturedPiece = pieceAt(move.newLocation)!
            let capturedIndex = pieces.firstIndex(matching: capturedPiece)!
            pieces.remove(at: capturedIndex)
        }
        
        let piece = pieceAt(move.oldLocation)!
        let index = pieces.firstIndex(matching: piece)!
        pieces[index].location = move.newLocation
        switchPlayers()
    }
    
    private func canMove(_ piece: Piece, to location: Square) -> Bool {
        validMove(piece, movingTo: location)
            && (canMoveHorizontally(piece, to: location)
                    || canMoveVertically(piece, to: location)
                    || canMoveDiagonally(piece, to: location))
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
        let opponentSquares = Set(pieces(for: opponent(of: piece.player)).map { $0.location })

        if piece.location.x == location.x {
            squaresOnPath = Set(squaresInColumnBetween(a: piece.location, b: location))
        } else if piece.location.y == location.y {
            squaresOnPath = Set(squaresInRowBetween(a: piece.location, b: location))
        } else {
            squaresOnPath = Set(squaresOnDiagonalBetween(a: piece.location, b: location))
        }
        
        return squaresOnPath.intersection(opponentSquares).count > 0
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
    
    // MARK: - Objects
    
    enum Player {
        case player, opponent
        
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

// MARK: - Agent

fileprivate struct Agent {
    fileprivate typealias Piece = GameBoard.Piece
    fileprivate typealias Square = GameBoard.Square
    fileprivate typealias Player = LinesOfAction.Player
    
    private var bestMove: Move?
    private var moveValues: [Int : [Int : Double]]
    
    init() {
        moveValues = Agent.computeMoveValues()
    }
    
    fileprivate mutating func move(board: GameBoard) -> Move? {
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
                nextBoard.move(move.piece, to: move.destination)
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
                nextBoard.move(move.piece, to: move.destination)
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
            let toIndex = move.destination.x + 8 * move.destination.y
            sumOfMoveValues += moveValues[fromIndex]![toIndex]! * (board.pieceAt(move.destination) != nil ? 2 : 1)
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
        var edges = [Int]()
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
    
    // MARK: - Objects
    
    fileprivate struct Move {
        let piece: Piece
        let destination: Square
        var value: Double = 0
        
        init(_ piece: Piece, to destination: Square) {
            self.piece = piece
            self.destination = destination
        }
        
        init(other: Move, value: Double) {
            self.piece = other.piece
            self.destination = other.destination
            self.value = value
        }
    }
}
