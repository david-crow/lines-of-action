//
//  LinesOfActionViewModel.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

class LinesOfActionViewModel: ObservableObject {
    @Published private var model: LinesOfAction = LinesOfAction()
    
    // MARK: - View Functionality
    
    @Published private(set) var playerName: String = "Player 1"
    @Published private(set) var opponentName: String = "Player 2"
    @Published private(set) var didAnalyze: Bool = false
    @Published var showValidMoves: Bool = true
    @Published var allowUndo: Bool = true
    @Published var showLastMove: Bool = false {
        didSet {
            if showLastMove {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.showLastMove = false
                })
            }
        }
    }
    
    var theme: Theme = Theme.themes[0]
        
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
    
    func analyze() {
        didAnalyze = true
    }
    
    // MARK: - Access to the Model
    
    var winner: LinesOfAction.Player? {
        model.winner
    }
    
    var piecesHaveBeenMoved: Bool {
        model.moves.count > 0
    }
    
    var gameIsOver: Bool {
        model.winner != nil
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
    
    func isActive(_ player: LinesOfAction.Player) -> Bool {
        player == model.activePlayer
    }
    
    func isSelected(x: Int, y: Int) -> Bool {
        model.isSelected(x, y)
    }
    
    func isLastMove(x: Int, y: Int) -> Bool {
        model.isLastMove(x, y)
    }
        
    func pieceAt(x: Int, y: Int) -> LinesOfAction.Piece? {
        model.pieceAt(x, y)
    }
    
    func canMoveTo(x: Int, y: Int) -> Bool {
        model.canMoveTo(x, y)
    }
    
    // MARK: - Intent(s)
    
    func resetGame() {
        model = LinesOfAction()
        didAnalyze = false
    }
    
    func concede() {
        model.concede()
    }
    
    func undo() {
        model.undo()
    }
    
    func selectSquare(x: Int, y: Int) {
        if let tappedPiece = model.pieceAt(x, y) {
            if model.selectedPieceIndex != nil && model.canMoveTo(x, y) {
                model.moveTo(x, y)
            } else if model.activePlayer == tappedPiece.player {
                model.select(tappedPiece)
            }
        } else if model.selectedPieceIndex != nil {
            if model.canMoveTo(x, y) {
                model.moveTo(x, y)
            } else {
                model.deselectAllPieces()
            }
        }
    }
}
