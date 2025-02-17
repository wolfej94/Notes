//
//  CreateViewModel.swift
//  NotesMVVM
//
//  Created by James Wolfe on 12/02/2025.
//

import NotesStorage
import UIKit

final class CreateViewModel: DetailViewModel {
    
    private var note: NoteViewModel?
    
    @MainActor
    override func save() async {
        let (title, body) = titleAndBody(ofText: text)
        let note = NoteViewModel(id: UUID(), title: title, body: body)
        do {
            try await notesCommandFactory
                .addCommand(note: note)
                .execute()
            repository.sendNoteUpdate(note)
            self.note = note
        } catch {
            await set(state: .error(message: error.localizedDescription))
        }
    }
}
