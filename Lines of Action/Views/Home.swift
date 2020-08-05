//
//  Home.swift
//  Lines of Action
//
//  Created by David Crow on 7/26/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct Home: View {
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    PieceIcon(color: firstLogoColor, maxDiameter: logoDiameter)
                        .rotationEffect(firstPieceRotation)
                        .offset(CGSize(width: -logoOffset, height: -logoOffset))
                    
                    PieceIcon(color: secondLogoColor, maxDiameter: logoDiameter)
                        .rotationEffect(secondPieceRotation)
                        .offset(CGSize(width: logoOffset, height: 0))
                }
                
                Text("Lines of Action")
                    .font(Font.largeTitle.weight(.heavy))
                    .padding(.vertical, titlePadding)
                
                NavigationLink(destination: Game(type: .solo)) {
                    NavigationButton(label: "Single Player")
                }
                
                NavigationLink(destination: Game(type: .offline)) {
                    NavigationButton(label: "Offline Multiplayer")
                }
                
                NavigationLink(destination: Game(type: .online)) {
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
    private let firstPieceRotation = Angle(degrees: 22.5)
    private let secondPieceRotation = Angle(degrees: 0)
    
    private var firstLogoColor: Color {
        Theme.themes[0].playerColor
    }
    
    private var secondLogoColor: Color {
        Theme.themes[0].opponentColor
    }
}

fileprivate struct NavigationButton: View {
    let label: String
    
    var body: some View {
        ZStack {
            Text(label)
            RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1)
        }
        .foregroundColor(.primary)
        .frame(maxWidth: 200, maxHeight: 50)
    }
}
