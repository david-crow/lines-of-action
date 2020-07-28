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
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    private func body(for size: CGSize) -> some View {
        VStack {
            HStack {
                Placard(for: .player, activePlayer: viewModel.activePlayer)
                Spacer()
                Placard(for: .opponent, activePlayer: viewModel.activePlayer)
            }

            ZStack {
                Board()
                    .environmentObject(viewModel)
                    .frame(maxWidth: UIScreen.main.bounds.width,
                           maxHeight: UIScreen.main.bounds.width)
                
                if viewModel.winner != nil {
                    EndGamePanel(winner: viewModel.winner!, size: size)
                        .frame(maxWidth: panelWidth(for: size), maxHeight: panelHeight(for: size))
                }
            }
            
            HStack {
                GameButton("Undo") {}
                GameButton("Show Last") {}
                GameButton("Concede") {}
            }
            .padding(.horizontal)
        }
        .navigationBarTitle("Player vs. Player", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                self.showSettingsPanel = true
            }, label: {
                Image(systemName: "gear")
                    .imageScale(.large)
            })
        )
        .sheet(isPresented: $showSettingsPanel) {
            GameSettings()
        }
    }
    
    // MARK: - Drawing Constants
    
    private func panelWidth(for size: CGSize) -> CGFloat {
        5/8 * min(size.width, size.height)
    }
    
    private func panelHeight(for size: CGSize) -> CGFloat {
        3/8 * min(size.width, size.height)
    }
}

struct GameButton: View {
    let label: String
    let action: () -> Void
    
    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: action, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1)
                Text(label)
            }
        })
        .frame(maxHeight: 50)
    }
}
