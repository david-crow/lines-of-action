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
        self.board = GameBoard(size: boardSize)
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
                board.undo(previousMove)
                moveCounter -= 1
            }
        }
    }
    
    func stepBackward() {
        if moveCounter >= 0 {
            board.undo(moves[moveCounter])
            moveCounter -= 1
        }
    }
    
    func stepForward() {
        if moveCounter < moves.count - 1 {
            board.redo(moves[moveCounter + 1])
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: { [self] in
            if gameType == .solo && winner == nil {
                if let move = agent!.move(board: board) {
                    selectedPieceIndex = board.pieces.firstIndex(matching: move.piece)
                    moveHelper(newLocation: move.newLocation)
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
}
