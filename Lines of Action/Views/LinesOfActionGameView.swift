//
//  LinesOfActionGameView.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct LinesOfActionGameView: View {
    @ObservedObject var viewModel: LinesOfActionGame
    
    var body: some View {
        VStack {
            HStack {
                Placard(for: .player, activePlayer: viewModel.activePlayer)
                Spacer()
                Placard(for: .opponent, activePlayer: viewModel.activePlayer)
            }
            
            Board()
                .environmentObject(viewModel)
                .frame(maxWidth: UIScreen.main.bounds.width,
                       maxHeight: UIScreen.main.bounds.width)
        }
    }
}
