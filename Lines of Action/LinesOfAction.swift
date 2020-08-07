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
    let boardSize: Int
    private let agent: Agent?
    
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
        self.boardSize = boardSize
        self.board = GameBoard.createBoard(size: boardSize)
        self.agent = gameType == .offline ? nil : Agent()
    }
    
    // MARK: - Public Accessors
    
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
    
    func isActive(_ player: LinesOfAction.Player) -> Bool {
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
        if let previousMove = moves.popLast() {
            board.undo(move: previousMove)
            moveCounter -= 1
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
        
        if gameType == .solo && winner == nil {
            if let move = agent!.move(board: board) {
                selectedPieceIndex = board.pieces.firstIndex(matching: move.piece)
                moveHelper(newLocation: move.destination)
            } else {
                winner = board.inactivePlayer
            }
        }
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
        
        return GameBoard(pieces: pieces, squares: squares)
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
    
    private func didWin(_ player: Player) -> Bool {
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
    
    fileprivate func findDestinations(for piece: Piece) -> [Square] {
        squares.filter { canMove(piece, to: $0) }
    }
    
    // MARK: - Mutators
    
    private mutating func switchPlayers() {
        activePlayer = opponent(of: activePlayer)
    }
    
    fileprivate mutating func move(_ piece: Piece, to newLocation: Square) -> Move {
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
    
    fileprivate func move(board: GameBoard) -> Move? {
        var moves: [Move] = []
        
        for piece in board.pieces(for: board.activePlayer) {
            let destinations = board.findDestinations(for: piece)
            moves += destinations.map { Move(piece, to: $0) }.map { Move(other: $0, value: value(of: $0)) }
        }
        
        return moves.sorted { $0.value > $1.value }.first
    }
    
    private func value(of move: Move) -> Int {
        Int.random(in: 0...100)
    }
    
    fileprivate struct Move {
        let piece: Piece
        let destination: Square
        var value: Int = 0
        
        init(_ piece: Piece, to destination: Square) {
            self.piece = piece
            self.destination = destination
        }
        
        init(other: Move, value: Int) {
            self.piece = other.piece
            self.destination = other.destination
            self.value = value
        }
    }
}
