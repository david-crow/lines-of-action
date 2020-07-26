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
        NavigationView {
            VStack {
                NavigationLink(destination: EmptyView()
                    .navigationBarTitle("Player vs. Computer")
                ) {
                    NavigationButton(label: "One Player")
                }
                
                NavigationLink(destination: Game(viewModel: LinesOfActionViewModel())
                    .navigationBarTitle("Player vs. Player")
                ) {
                    NavigationButton(label: "Two Player")
                }
                
                NavigationLink(destination: EmptyView()
                    .navigationBarTitle("Player vs. Player")
                ) {
                    NavigationButton(label: "Network Play")
                }
                
                NavigationLink(destination: EmptyView()
                    .navigationBarTitle("How to Play")
                ) {
                    NavigationButton(label: "How to Play")
                }
                
                NavigationLink(destination: EmptyView()
                    .navigationBarTitle("Settings")
                ) {
                    NavigationButton(label: "Settings")
                }
            }
            .navigationBarTitle("Lines of Action")
        }
    }
}

struct NavigationButton: View {
    let label: String
    
    var body: some View {
        ZStack {
            Text(label)
            RoundedRectangle(cornerRadius: 10).stroke()
        }
        .foregroundColor(.black)
        .frame(maxWidth: 200, maxHeight: 50)
    }
}
