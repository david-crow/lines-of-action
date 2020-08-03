//
//  GameSettings.swift
//  Lines of Action
//
//  Created by David Crow on 7/26/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct GameSettings: View {
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var viewModel: LinesOfActionViewModel
    
    @State private var playerName: String = ""
    @State private var opponentName: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    private func body(for size: CGSize) -> some View {
        NavigationView {
            Form {
                Section(header: Text("Names")) {
                    TextField("Player 1", text: $viewModel.playerName)
                    TextField("Player 2", text: $viewModel.opponentName)
                }
                
                Section(header: Text("Options")) {
                    Toggle(isOn: $viewModel.showValidMoves) { Text("Show Valid Moves") }
                    Toggle(isOn: $viewModel.allowUndo) { Text("Enable Undo Button") }
                    Toggle(isOn: $viewModel.animateMoves) { Text("Animate Movement") }
                }
                
                Section(header: Text("Theme")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Theme.themes) { theme in
                                ThemeView(for: theme, size: size).environmentObject(self.viewModel)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: done)
        }
        .onAppear {
            self.playerName = self.viewModel.name(for: .player)
            self.opponentName = self.viewModel.name(for: .opponent)
        }
    }
    
    private var done: some View {
        Button("Done") {
            self.presentation.wrappedValue.dismiss()
        }
    }
}
