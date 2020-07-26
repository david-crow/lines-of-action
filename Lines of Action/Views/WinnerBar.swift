//
//  WinnerBar.swift
//  Lines of Action
//
//  Created by David Crow on 7/26/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct WinnerBar: View {
    let winner: LinesOfAction.Player
    let size: CGSize
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(maxHeight: barHeight)

            HStack {
                PieceIcon(player: winner, maxDiameter: contentHeight)
                Text("Winner!").font(Font.system(size: contentHeight))
                PieceIcon(player: winner, maxDiameter: contentHeight)
            }
        }
    }
    
    // MARK: - Drawing Constants
    
    private var barHeight: CGFloat {
        0.2 * min(size.height, size.width)
    }
    
    private var contentHeight: CGFloat {
        0.75 * barHeight
    }
}
