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
    let firstSquareColor: Color
    let secondSquareColor: Color
    let highlightColor: Color = .yellow
    let id: UUID = UUID()
    
    static var themes = [
        Theme(
            name: "Classic",
            playerColor: Color(#colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1))),
        Theme(
            name: "Canyon",
            playerColor: Color(#colorLiteral(red: 0.7568627451, green: 0.4, blue: 0.1960784314, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.2745098039, green: 0.4039215686, blue: 0.4980392157, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.5921568627, green: 0.6039215686, blue: 0.6039215686, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.8156862745, green: 0.8274509804, blue: 0.831372549, alpha: 1))),
        Theme(
            name: "Desert",
            playerColor: Color(#colorLiteral(red: 0.07450980392, green: 0.5921568627, blue: 0.6274509804, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.7960784314, green: 0.2705882353, blue: 0.2392156863, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.9529411765, green: 0.6980392157, blue: 0.3450980392, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.9803921569, green: 0.7647058824, blue: 0.5058823529, alpha: 1))),
        Theme(
            name: "Glacier",
            playerColor: Color(#colorLiteral(red: 0.1294117647, green: 0.3803921569, blue: 0.5490196078, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.03921568627, green: 0.03921568627, blue: 0.1960784314, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.6980392157, green: 0.7411764706, blue: 0.7843137255, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.8352941176, green: 0.8470588235, blue: 0.862745098, alpha: 1))),
        Theme(
            name: "Meadow",
            playerColor: Color(#colorLiteral(red: 0.5058823529, green: 0.3803921569, blue: 0.2352941176, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.6470588235, green: 0.7333333333, blue: 0.5215686275, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.8274509804, alpha: 1))),
        Theme(
            name: "Pond",
            playerColor: Color(#colorLiteral(red: 0.6039215686, green: 0.6196078431, blue: 0.2549019608, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.168627451, green: 0.3450980392, blue: 0.5294117647, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.8117647059, green: 0.6862745098, blue: 0.5450980392, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.8705882353, green: 0.7843137255, blue: 0.6862745098, alpha: 1))),
    ]
}

struct ThemeView: View {
    @EnvironmentObject var viewModel: LinesOfActionViewModel
    
    let theme: Theme
    let size: CGSize
    
    init(for theme: Theme, size: CGSize) {
        self.theme = theme
        self.size = size
    }
    
    var body: some View {
        VStack {
            ThemeBoard(for: theme, size: size)
            Text(theme.name)
            Image(systemName: "checkmark").opacity(theme == viewModel.theme ? 1 : 0)
        }
        .padding()
        .onTapGesture { self.viewModel.theme = self.theme }
    }
    
    private struct ThemeBoard: View {
        let theme: Theme
        let size: CGSize
        
        init(for theme: Theme, size: CGSize) {
            self.theme = theme
            self.size = size
        }
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(0..<2) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<2) { col in
                            ZStack {
                                Rectangle()
                                    .fill(self.colorForSquare(x: col, y: row))
                                    .overlay(Rectangle().stroke())
                                    .frame(width: self.squareSize, height: self.squareSize)
                                
                                self.piece(x: col, y: row, maxDiameter: self.squareSize)
                            }
                        }
                    }
                }
            }
        }
        
        // MARK: - Drawing Constants

        private var themeSize: CGFloat {
            0.25 * min(size.width, size.height)
        }
        
        private var squareSize: CGFloat {
            0.5 * themeSize
        }
        
        private func colorForSquare(x: Int, y: Int) -> Color {
            (x + y) % 2 == 0 ? theme.firstSquareColor : theme.secondSquareColor
        }
        
        private func piece(x: Int, y: Int, maxDiameter: CGFloat) -> PieceIcon? {
            if x == y {
                return PieceIcon(color: x == 0 ? theme.playerColor : theme.opponentColor, maxDiameter: squareSize)
            }
            return nil
        }
    }
}
