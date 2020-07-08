//
//  Square.swift
//  Lines of Action
//
//  Created by David Crow on 7/9/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Square: View {
    let hasPiece: Bool
    let color: Color
    let selected: Bool
    let highlighted: Bool
    let boardSize: Int
    let size: CGSize

    var body: some View {
        ZStack {
            Rectangle().fill(selected ? Color.yellow : color)
            if highlighted {
                if hasPiece {
                    VStack {
                        HStack {
                            Spacer()
                            Token(size: tokenSize, color: tokenColor).padding([.trailing, .top], tokenPadding)
                        }
                        Spacer()
                    }
                } else {
                    Token(size: tokenSize, color: tokenColor)
                }
            }
        }
    }
    
    struct Token: View {
        let size: CGFloat
        let color: Color
        
        var body: some View {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
    }
    
    // MARK: - Drawing Constants
    
    private let tokenScale: CGFloat = 0.15
    private let tokenColor: Color = .yellow
    private let tokenPadding: CGFloat = 5
    
    private var tokenSize: CGFloat {
        tokenScale * min(size.width, size.height) / CGFloat(boardSize)
    }
}

//struct Square_Previews: PreviewProvider {
//    static var previews: some View {
//        Square()
//    }
//}
