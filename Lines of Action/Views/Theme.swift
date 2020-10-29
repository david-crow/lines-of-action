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
    let highlightColor: Color = Color(#colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1))
    let id: UUID = UUID()
    
    static let icons = [
        "atom", "plus", "ladybug.fill", "sparkle", "moon.fill",
        "star.fill", "cross.fill", "diamond.fill", "circle.fill"
    ]
    
    static let themes = [
        Theme(
            name: "Classic",
            playerColor: Color(#colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1))),
        Theme(
            name: "Dune",
            playerColor: Color(#colorLiteral(red: 0.07450980392, green: 0.5921568627, blue: 0.6274509804, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.7960784314, green: 0.2705882353, blue: 0.2392156863, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.8823529412, green: 0.7490196078, blue: 0.5725490196, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.9490196078, green: 0.8235294118, blue: 0.662745098, alpha: 1))),
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
            name: "Mesa",
            playerColor: Color(#colorLiteral(red: 0.7568627451, green: 0.4, blue: 0.1960784314, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.2745098039, green: 0.4039215686, blue: 0.4980392157, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.5921568627, green: 0.6039215686, blue: 0.6039215686, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.8156862745, green: 0.8274509804, blue: 0.831372549, alpha: 1))),
        Theme(
            name: "Pond",
            playerColor: Color(#colorLiteral(red: 0.6039215686, green: 0.6196078431, blue: 0.2549019608, alpha: 1)),
            opponentColor: Color(#colorLiteral(red: 0.168627451, green: 0.3450980392, blue: 0.5294117647, alpha: 1)),
            firstSquareColor: Color(#colorLiteral(red: 0.8117647059, green: 0.6862745098, blue: 0.5450980392, alpha: 1)),
            secondSquareColor: Color(#colorLiteral(red: 0.8705882353, green: 0.7843137255, blue: 0.6862745098, alpha: 1))),
    ]
}

struct IconView: View {
    @EnvironmentObject var viewModel: LinesOfActionViewModel
    
    let icon: String
    let size: CGSize
        
    init(for icon: String, size: CGSize) {
        self.icon = icon
        self.size = size
    }
    
    var body: some View {
        VStack {
            PieceIcon(icon: icon, color: viewModel.theme.playerColor, maxDiameter: pieceSize).padding(.bottom, 5)
            Image(systemName: "checkmark").opacity(icon == viewModel.icon ? 1 : 0)
        }
        .padding()
        .onTapGesture { viewModel.icon = icon }
    }
    
    private var pieceSize: CGFloat {
        0.15 * min(size.width, size.height)
    }
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
            ThemeBoard(for: theme, icon: viewModel.icon, size: size)
            Text(theme.name).padding(.bottom, 5)
            Image(systemName: "checkmark").opacity(theme == viewModel.theme ? 1 : 0)
        }
        .padding()
        .onTapGesture { viewModel.theme = theme }
    }
    
    private struct ThemeBoard: View {
        let theme: Theme
        let icon: String
        let size: CGSize
        
        init(for theme: Theme, icon: String, size: CGSize) {
            self.theme = theme
            self.icon = icon
            self.size = size
        }
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(0..<2) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<2) { col in
                            ZStack {
                                Rectangle()
                                    .fill(colorForSquare(x: col, y: row))
                                    .overlay(Rectangle().stroke())
                                    .frame(width: squareSize, height: squareSize)
                                
                                piece(x: col, y: row, maxDiameter: squareSize)
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
                return PieceIcon(icon: icon, color: x == 0 ? theme.playerColor : theme.opponentColor, maxDiameter: squareSize)
            }
            return nil
        }
    }
}
