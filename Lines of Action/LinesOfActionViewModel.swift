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
    @Published var showValidMoves: Bool = true
    
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
    
    // MARK: - Access to the Model
    
    var winner: LinesOfAction.Player? {
        model.winner
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
    
    func pieceAt(x: Int, y: Int) -> LinesOfAction.Piece? {
        model.pieceAt(x, y)
    }
    
    func canMoveTo(x: Int, y: Int) -> Bool {
        model.canMoveTo(x, y)
    }
    
    // MARK: - Intent(s)
    
    func concede() {
        model.concede()
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
