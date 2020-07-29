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
        NavigationView {
            Form {
                Section {
                    TextField("Player 1", text: $playerName, onEditingChanged: { began in
                        if !began {
                            self.viewModel.changeName(for: .player, newName: self.playerName)
                        }
                    })
                    
                    TextField("Player 2", text: $opponentName, onEditingChanged: { began in
                        if !began {
                            self.viewModel.changeName(for: .opponent, newName: self.opponentName)
                        }
                    })
                }
                
                Section {
                    Toggle(isOn: $viewModel.showValidMoves) { Text("Show Valid Moves") }
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
