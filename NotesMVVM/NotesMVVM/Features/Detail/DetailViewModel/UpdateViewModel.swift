//
//  UpdateViewModel.swift
//  NotesMVVM
//
//  Created by James Wolfe on 12/02/2025.
//

import NotesStorage
import SwiftUI

final class UpdateViewModel: DetailViewModel {
    
    private var note: NoteViewModel
    @Binding private var notes: Set<NoteViewModel>
    
    init(note: NoteViewModel,
         notes: Binding<Set<NoteViewModel>>,
         notesCommandFactory: NotesCommandFactory) {
        self.note = note
        _notes = notes
        super.init(notesCommandFactory: notesCommandFactory)
        setupText()
    }
    
    @MainActor
    override func save() async {
        var note = note
        let (title, body) = titleAndBody(ofText: text)
        note.title = title
        note.body = body
        do {
            try await notesCommandFactory
                .updateCommand(note: note)
                .execute()
            self.note = note
            notes.update(with: note)
        } catch {
            await set(state: .error(message: error.localizedDescription))
        }
    }
    
}



// MARK: - Setup
private extension UpdateViewModel {
    
    func setupText() {
        text = [note.title, note.body]
            .compactMap { $0 }
            .joined(separator: "\n")
    }
    
}
