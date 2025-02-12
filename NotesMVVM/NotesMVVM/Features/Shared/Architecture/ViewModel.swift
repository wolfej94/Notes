//
//  ViewModel.swift
//  NotesMVVM
//
//  Created by James Wolfe on 31/01/2025.
//

import SwiftUI

open class ViewModel {
    
    private(set) var state: UIState
    
    init(state: UIState) {
        self.state = state
    }
    
    func set(state: UIState, animated: Bool = true) async {
        await MainActor.run {
            set(state: state)
        }
    }
    
    func set(state: UIState, animated: Bool = true) {
        if animated {
            withAnimation {
                self.state = state
            }
        } else {
            self.state = state
        }
    }
    
}
