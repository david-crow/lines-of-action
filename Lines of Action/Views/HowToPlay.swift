//
//  HowToPlay.swift
//  Lines of Action
//
//  Created by David Crow on 10/17/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct HowToPlay: View {
    var body: some View {
        Form {
            Section(header: Text("Objective")) {
                Text("Move your pieces until they form a single, connected group. Pieces can be connected horizontally, vertically, and diagonally.")
            }
            
            Section(header: Text("Rules")) {
                Text("Black (or the player along the top and bottom rows) moves first.")
                Text("On your turn, you must move one of your pieces, in a straight line, exactly as many squares as there are pieces of either color anywhere along the line of movement. (These are the Lines of Action).")
                Text("You may jump over your own pieces.")
                Text("You may not jump over your opponent's pieces, but you can capture them by landing on them.")
            }
            
            Section(header: Text("Uncommon Situations")) {
                Text("If a player cannot move, that player loses.")
                Text("If one player is reduced by captures to a single piece, that player wins.")
                Text("If a move simultaneously creates a single connected unit for both the player moving and the opponent, the player moving wins.")
            }
        }
        .navigationBarTitle("How to Play", displayMode: .inline)
    }
}
