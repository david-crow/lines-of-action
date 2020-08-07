//
//  Game.swift
//  Lines of Action
//
//  Created by David Crow on 7/4/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct Game: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var viewModel: LinesOfActionViewModel
    
    @State private var showSettingsPanel = false
    @State private var didConcede = false
    
    init(type: LinesOfAction.GameType) {
        viewModel = LinesOfActionViewModel(gameType: type)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    
                    Placard(viewModel: viewModel)
                    
                    Board()
                        .environmentObject(viewModel)
                        .allowsHitTesting(canTapBoard)
                        .frame(maxWidth: UIScreen.main.bounds.width,
                               maxHeight: UIScreen.main.bounds.width)
                    
                    VStack {
                        if viewModel.gameMode == .playing {
                            HStack {
                                GameButton("Undo") { viewModel.undo() }
                                    .disabled(!canUndo)
                                GameButton("Show Last") { viewModel.showingPreviousMove = true }
                                    .disabled(!canShowLast)
                                GameButton("Concede") { didConcede = true }
                            }
                        } else {
                            HStack {
                                GameButton(icon: "arrowtriangle.left") { viewModel.stepBackward() }
                                    .disabled(!viewModel.canStepBackward)
                                GameButton(icon: "arrowtriangle.right") { viewModel.stepForward() }
                                    .disabled(!viewModel.canStepForward)
                                GameButton("Best Move") {}
                            }
                            .disabled(viewModel.gameMode != .analysis)
                        }
                        
                        GameButton("New Game") { viewModel.resetGame() }
                            .opacity(viewModel.gameMode == .analysis ? 1 : 0)
                            .disabled(viewModel.gameMode != .analysis)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                if viewModel.gameMode == .gameOver {
                    VisualEffectView(effect: UIBlurEffect(style: .regular)).edgesIgnoringSafeArea(.all)
                    EndGamePanel().environmentObject(viewModel)
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: { showSettingsPanel = true }) {
                    Image(systemName: "gear").imageScale(.large)
                }
            )
            .sheet(isPresented: $showSettingsPanel) {
                GameSettings().environmentObject(viewModel)
            }
            .alert(isPresented: $didConcede) {
                Alert(
                    title: Text("Concede this game?"),
                    primaryButton: .default(Text("Concede")) { viewModel.concede() },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private var canTapBoard: Bool {
        viewModel.gameMode == .playing
            && (viewModel.gameType == .offline || viewModel.isActive(.player))
    }
    
    private var title: String {
        viewModel.gameMode == .analysis ? "Analysis" : viewModel.gameType.rawValue
    }
    
    private var canUndo: Bool {
        viewModel.allowUndo && viewModel.piecesHaveBeenMoved
    }
    
    private var canShowLast: Bool {
        !viewModel.showingPreviousMove && viewModel.piecesHaveBeenMoved
    }
}

fileprivate struct GameButton: View {
    let label: String?
    let systemName: String?
    let action: () -> Void
    
    init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.systemName = nil
        self.action = action
    }
    
    init(icon systemName: String, action: @escaping () -> Void) {
        self.label = nil
        self.systemName = systemName
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius).stroke()
                
                if label != nil {
                    Text(label!)
                }
                
                if systemName != nil {
                    Image(systemName: systemName!).imageScale(.large)
                }
            }
        }
        .frame(maxHeight: maxHeight)
    }
    
    // MARK: - Drawing Constants
    
    private let cornerRadius: CGFloat = 10
    private let maxHeight: CGFloat = 50
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
