//
//  Home.swift
//  Lines of Action
//
//  Created by David Crow on 7/26/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Home: View {
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    private func body(for size: CGSize) -> some View {
        NavigationView {
            VStack {
                ZStack {
                    PieceIcon(player: .player, maxDiameter: logoDiameter)
                        .offset(CGSize(width: -logoOffset, height: -logoOffset))
                    
                    PieceIcon(player: .opponent, maxDiameter: logoDiameter)
                        .offset(CGSize(width: logoOffset, height: 0))
                }
                
                Text("Lines of Action")
                    .font(Font.largeTitle.weight(.heavy))
                    .padding(.vertical, titlePadding)
                
                NavigationLink(destination: EmptyView().navigationBarTitle("todo", displayMode: .inline)) {
                    NavigationButton(label: "Single Player")
                }
                
                NavigationLink(destination: Game(viewModel: LinesOfActionViewModel())) {
                    NavigationButton(label: "Offline Multiplayer")
                }
                
                NavigationLink(destination: EmptyView().navigationBarTitle("todo", displayMode: .inline)) {
                    NavigationButton(label: "Online Multiplayer")
                }
                
                NavigationLink(destination: EmptyView().navigationBarTitle("todo", displayMode: .inline)) {
                    NavigationButton(label: "How to Play")
                }
                
                NavigationLink(destination: EmptyView().navigationBarTitle("todo", displayMode: .inline)) {
                    NavigationButton(label: "Settings")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Drawing Constants
    
    private let logoDiameter: CGFloat = 200
    private let logoOffset: CGFloat = 40
    private let titlePadding: CGFloat = 25
}

struct NavigationButton: View {
    let label: String
    
    var body: some View {
        ZStack {
            Text(label)
            RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1)
        }
        .foregroundColor(.black)
        .frame(maxWidth: 200, maxHeight: 50)
    }
}
