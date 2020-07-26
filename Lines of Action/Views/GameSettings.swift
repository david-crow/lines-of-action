//
//  GameSettings.swift
//  Lines of Action
//
//  Created by David Crow on 7/26/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct GameSettings: View {
    @Environment(\.presentationMode) var presentation
        
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Hello World")
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(leading: cancel, trailing: done)
        }
    }
    
    private var cancel: some View {
        Button("Cancel") {
            self.presentation.wrappedValue.dismiss()
        }
    }
    
    private var done: some View {
        Button("Done") {
            self.presentation.wrappedValue.dismiss()
        }
    }
}
