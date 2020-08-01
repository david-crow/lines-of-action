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
        VStack {
            Placard(viewModel: viewModel)
            
            ZStack {
                Board()
                    .environmentObject(viewModel)
                    .allowsHitTesting(!viewModel.gameIsOver)
                    .frame(maxWidth: UIScreen.main.bounds.width,
                           maxHeight: UIScreen.main.bounds.width)
                
                if viewModel.gameIsOver && !viewModel.didAnalyze {
                    EndGamePanel(size: size)
                        .environmentObject(viewModel)
                        .frame(maxWidth: panelWidth(for: size), maxHeight: panelHeight(for: size))
                }
            }
            
            HStack {
                GameButton("Undo") { self.viewModel.undo() }
                    .disabled(!viewModel.allowUndo || !viewModel.piecesHaveBeenMoved)
                
                GameButton("Show Last") { self.viewModel.showLastMove = true }
                    .disabled(viewModel.showLastMove || !viewModel.piecesHaveBeenMoved)
                
                GameButton("Concede") { self.didConcede = true }
            }
            .padding(.horizontal)
            .disabled(viewModel.gameIsOver)
            
            GameButton("New Game") { self.viewModel.resetGame() }
                .padding(.horizontal)
                .opacity(viewModel.didAnalyze ? 1 : 0)
                .disabled(!viewModel.didAnalyze)
        }
        .navigationBarTitle("Offline Multiplayer", displayMode: .inline)
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
    
    // MARK: - Drawing Constants
    
    private func panelWidth(for size: CGSize) -> CGFloat {
        5 / 8 * min(size.width, size.height)
    }
    
    private func panelHeight(for size: CGSize) -> CGFloat {
        3 / 8 * min(size.width, size.height)
    }
}

fileprivate struct GameButton: View {
    let label: String
    let action: () -> Void
    
    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1)
                Text(label)
            }
        }
        .frame(maxHeight: 50)
    }
}
