//
//  Theme.swift
//  Lines of Action
//
//  Created by David Crow on 7/28/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Theme: Identifiable, Hashable {
    let name: String
    let playerColor: Color
    let opponentColor: Color
    let id = UUID()
    
    static var themes = [
        Theme(name: "Classic", playerColor: .red, opponentColor: .blue),
        Theme(name: "Neon", playerColor: .orange, opponentColor: .pink),
        Theme(name: "Marble", playerColor: .gray, opponentColor: .yellow),
        Theme(name: "Wood", playerColor: .green, opponentColor: .black)
    ]
}

struct ThemeView: View {
    let theme: Theme
    let size: CGSize
    
    var body: some View {
        ZStack {
            Rectangle().stroke()
            Text(theme.name)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
