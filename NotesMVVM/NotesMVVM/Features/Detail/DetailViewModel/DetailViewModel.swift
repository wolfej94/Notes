//
//  DetailViewModel.swift
//  NotesMVVM
//
//  Created by James Wolfe on 31/01/2025.
//

import NotesStorage
import SwiftUI

class DetailViewModel: ViewModel, ObservableObject {
    
    // MARK: - Data
    
    let notesCommandFactory: NotesCommandFactory
    @Published var isEditing: Bool
    @Published var text = ""
    
    // MARK: - Initialization
    init(notesCommandFactory: NotesCommandFactory) {
        self.notesCommandFactory = notesCommandFactory
        self.isEditing = true
        super.init(state: .loaded)
    }
    
    @MainActor
    public func save() async {
        fatalError("Save has not been implemented")
    }
    
}

// MARK: Helpers
extension DetailViewModel {
    
    func titleAndBody(ofText text: String) -> (title: String, body: String) {
        let titleAndBody = text.split(separator: "\n", maxSplits: 1)
        let title = String(titleAndBody.first ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let body = String(titleAndBody.last ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (title: title, body: body)
    }
    
}
