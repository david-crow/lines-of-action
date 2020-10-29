//
//  GameSettings.swift
//  Lines of Action
//
//  Created by David Crow on 7/26/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct GameSettings: View {
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var viewModel: LinesOfActionViewModel
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                Form {
                    Section(header: Text("Names")) {
                        TextField("Player 1", text: $viewModel.playerName, onCommit: {
                            UIApplication.shared.endEditing()
                        })
                        TextField("Player 2", text: $viewModel.opponentName, onCommit: {
                            UIApplication.shared.endEditing()
                        })
                    }
                    
                    Section(header: Text("Options")) {
                        Toggle(isOn: $viewModel.showValidMoves) { Text("Show Valid Moves") }
                        Toggle(isOn: $viewModel.allowUndo) { Text("Enable Undo Button") }
                        Toggle(isOn: $viewModel.animateMoves) { Text("Animate Movement") }
                    }
                    
                    Section(header: Text("Theme")) {
                        ScrollView(.horizontal) {
                            ScrollViewReader { scrollView in
                                icons(for: geometry.size)
                                .onAppear {
                                    scrollView.scrollTo(viewModel.icon)
                                }
                            }
                        }
                        
                        ScrollView(.horizontal) {
                            ScrollViewReader { scrollView in
                                themes(for: geometry.size)
                                .onAppear {
                                    scrollView.scrollTo(viewModel.theme)
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Settings", displayMode: .inline)
                .navigationBarItems(trailing: done)
            }
        }
    }
    
    private var done: some View {
        Button("Done") {
            presentation.wrappedValue.dismiss()
        }
    }
    
    private func icons(for size: CGSize) -> some View {
        HStack {
            ForEach(Theme.icons, id: \.self) { icon in
                IconView(for: icon, size: size).environmentObject(viewModel)
            }
        }
    }
    
    private func themes(for size: CGSize) -> some View {
        HStack {
            ForEach(Theme.themes, id: \.self) { theme in
                ThemeView(for: theme, size: size).environmentObject(viewModel)
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
