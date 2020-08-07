//
//  LinesOfActionViewModel.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI
import Combine

class LinesOfActionViewModel: ObservableObject {
    typealias GameType = LinesOfAction.GameType
    typealias GameMode = LinesOfAction.GameMode
    typealias Player = GameBoard.Player
    typealias Piece = GameBoard.Piece
    typealias Square = GameBoard.Square
    
    @ObservedObject private var model: LinesOfAction
    
    private var modelCancellable: AnyCancellable?
    
    init(gameType: GameType) {
        model = LinesOfAction(gameType: gameType)
        modelCancellable = model.objectWillChange.sink { [self] in
            objectWillChange.send()
        }
    }
    
    // MARK: - View Functionality
    
    @Published var playerName: String = "Player 1"
    @Published var opponentName: String = "Player 2"
    @Published var theme: Theme = Theme.themes[0]
    @Published var showValidMoves: Bool = true
    @Published var allowUndo: Bool = true
    @Published var animateMoves: Bool = true
    @Published var showingPreviousMove: Bool = false {
        didSet {
            if showingPreviousMove {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [self] in
                    showingPreviousMove = false
                })
            }
        }
    }
    
    func name(for player: Player) -> String {
        player == .player ? playerName : opponentName
    }
    
    func changeName(for player: Player, newName name: String) {
        if player == .player {
            playerName = name
        } else {
            opponentName = name
        }
    }
    
    var canStepBackward: Bool {
        model.canStepBackward
    }
    
    var canStepForward: Bool {
        model.canStepForward
    }
    
    // MARK: - Access to the Model
    
    var gameType: GameType {
        model.gameType
    }
    
    var gameMode: GameMode {
        model.gameMode
    }
    
    var boardSize: Int {
        model.boardSize
    }
    
    var pieces: [Piece] {
        model.board.pieces
    }
    
    var winner: Player? {
        model.winner
    }
    
    var piecesHaveBeenMoved: Bool {
        model.piecesHaveBeenMoved
    }
    
    var inFinalState: Bool {
        model.inFinalState
    }
    
    func isActive(_ player: Player) -> Bool {
        model.isActive(player)
    }
    
    func isSelected(x: Int, y: Int) -> Bool {
        model.isSelected(Square(x, y))
    }
    
    func isPreviousMove(x: Int, y: Int) -> Bool {
        model.isPreviousMove(Square(x, y))
    }
    
    func canMoveTo(x: Int, y: Int) -> Bool {
        model.canMoveTo(Square(x, y))
    }
    
    // MARK: - Intent(s)
    
    func resetGame() {
        modelCancellable?.cancel()
        model = LinesOfAction(gameType: model.gameType)
        modelCancellable = model.objectWillChange.sink { [self] in
            objectWillChange.send()
        }
        objectWillChange.send()
    }
    
    func concede() {
        model.concede()
    }
    
    func analyze() {
        model.analyze()
    }
    
    func selectSquare(x: Int, y: Int) {
        model.select(Square(x, y))
    }
    
    func undo() {
        model.undo()
    }
    
    func stepBackward() {
        model.stepBackward()
    }
    
    func stepForward() {
        model.stepForward()
    }
}
