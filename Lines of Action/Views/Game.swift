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
                    WinnerBar(winner: viewModel.winner!, size: size)
                }
            }
            
            HStack {
                GameButton(label: "Undo")
                GameButton(label: "Show Last")
                GameButton(label: "Concede")
                GameButton(label: "Rules")
            }
            .padding(.horizontal)
        }
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
}

struct GameButton: View {
    let label: String
    
    var body: some View {
        ZStack {
            Text(label)
            RoundedRectangle(cornerRadius: 10).stroke()
        }
        .foregroundColor(.black)
        .frame(maxHeight: 50)
    }
}
