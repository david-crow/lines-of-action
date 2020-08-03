//
//  Game.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Game: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var viewModel: LinesOfActionViewModel
    
    @State private var showSettingsPanel = false
    @State private var didConcede = false
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    private func body(for size: CGSize) -> some View {
        ZStack {
            VStack {
                Placard(viewModel: viewModel)
                
                Board()
                    .environmentObject(viewModel)
                    .allowsHitTesting(viewModel.gameMode == .playing)
                    .frame(maxWidth: UIScreen.main.bounds.width,
                           maxHeight: UIScreen.main.bounds.width)
                
                VStack {
                    if viewModel.gameMode == .playing {
                        HStack {
                            GameButton("Undo") { self.viewModel.undo() }
                                .disabled(!canUndo)
                            GameButton("Show Last") { self.viewModel.showingLastMove = true }
                                .disabled(!canShowLast)
                            GameButton("Concede") { self.didConcede = true }
                        }
                    } else {
                        HStack {
                            GameButton(icon: "arrowtriangle.left") { self.viewModel.previousMove() }
                                .disabled(!canMakePreviousMove)
                            GameButton(icon: "arrowtriangle.right") { self.viewModel.nextMove() }
                                .disabled(!canMakeNextMove)
                            GameButton("Best Move") {}
                        }
                        .disabled(viewModel.gameMode != .analysis)
                    }
                    
                    GameButton("New Game") { self.viewModel.resetGame() }
                        .opacity(viewModel.gameMode == .analysis ? 1 : 0)
                        .disabled(viewModel.gameMode != .analysis)
                }
                .padding(.horizontal)
            }
            .blur(radius: viewModel.gameMode == .gameOver ? blurRadius : 0)
            
            if viewModel.gameMode == .gameOver {
                EndGamePanel()
                    .environmentObject(viewModel)
                    .frame(maxWidth: panelWidth(for: size), maxHeight: panelHeight(for: size))
            }
        }
        .navigationBarTitle(viewModel.gameMode == .analysis ? "Analysis" : "Offline Multiplayer", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: { self.showSettingsPanel = true }) {
                Image(systemName: "gear").imageScale(.large)
            }
        )
        .sheet(isPresented: $showSettingsPanel) {
            GameSettings().environmentObject(self.viewModel)
        }
        .alert(isPresented: $didConcede) {
            Alert(
                title: Text("Concede this game?"),
                primaryButton: .default(Text("Concede")) { self.viewModel.concede() },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var canUndo: Bool {
        viewModel.allowUndo && viewModel.piecesHaveBeenMoved
    }
    
    private var canShowLast: Bool {
        !viewModel.showingLastMove && viewModel.piecesHaveBeenMoved
    }
    
    private var canMakePreviousMove: Bool {
        viewModel.canMakePreviousMove
    }
    
    private var canMakeNextMove: Bool {
        viewModel.canMakeNextMove
    }
    
    // MARK: - Drawing Constants
    
    private let blurRadius: CGFloat = 10
    
    private func panelWidth(for size: CGSize) -> CGFloat {
        1 / 2 * min(size.width, size.height)
    }
    
    private func panelHeight(for size: CGSize) -> CGFloat {
        1 / 3 * min(size.width, size.height)
    }
}

fileprivate struct GameButton: View {
    let label: String?
    let systemName: String?
    let action: () -> Void
    
    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
        self.systemName = nil
    }
    
    init(icon systemName: String, action: @escaping () -> Void) {
        self.systemName = systemName
        self.action = action
        self.label = nil
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1)
                
                if label != nil {
                    Text(label!)
                }
                
                if systemName != nil {
                    Image(systemName: systemName!).imageScale(.large)
                }
            }
        }
        .frame(maxHeight: 50)
    }
}
