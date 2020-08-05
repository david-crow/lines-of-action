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
    @ObservedObject private var model: LinesOfAction
    
    private var modelCancellable: AnyCancellable?
    
    init(gameType: LinesOfAction.GameType) {
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
    @Published var showingLastMove: Bool = false {
        didSet {
            if showingLastMove {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [self] in
                    showingLastMove = false
                })
            }
        }
    }
    
    func name(for player: LinesOfAction.Player) -> String {
        player == .player ? playerName : opponentName
    }
    
    func changeName(for player: LinesOfAction.Player, newName name: String) {
        if player == .player {
            playerName = name
        } else {
            opponentName = name
        }
    }
    
    var canMakePreviousMove: Bool {
        model.canMakePreviousMove
    }
    
    var canMakeNextMove: Bool {
        model.canMakeNextMove
    }
    
    // MARK: - Access to the Model
    
    var gameType: LinesOfAction.GameType {
        model.gameType
    }
    
    var gameMode: LinesOfAction.GameMode {
        model.gameMode
    }
    
    var boardSize: Int {
        model.boardSize
    }
    
    var squares: [LinesOfAction.Square] {
        model.squares
    }
    
    var pieces: [LinesOfAction.Piece] {
        model.pieces
    }
    
    var winner: LinesOfAction.Player? {
        model.winner
    }
    
    var piecesHaveBeenMoved: Bool {
        model.piecesHaveBeenMoved
    }
    
    var inFinalState: Bool {
        model.inFinalState
    }
    
    func isActive(_ player: LinesOfAction.Player) -> Bool {
        model.isActive(player)
    }
    
    func isSelected(x: Int, y: Int) -> Bool {
        model.isSelected(x, y)
    }
    
    func isLastMove(x: Int, y: Int) -> Bool {
        model.isLastMove(x, y)
    }
    
    func canMoveTo(x: Int, y: Int) -> Bool {
        model.canMoveTo(x, y)
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
        model.selectSquare(x, y)
    }
    
    func undo() {
        model.undo()
    }
    
    func previousMove() {
        model.previousMove()
    }
    
    func nextMove() {
        model.nextMove()
    }
}
