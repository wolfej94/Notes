//
//  UpdateViewModel.swift
//  NotesMVVM
//
//  Created by James Wolfe on 12/02/2025.
//

import NotesStorage

final class UpdateViewModel: DetailViewModel {
    
    private var note: NoteViewModel
    
    init(note: NoteViewModel,
         repository: NotesEventStream = DefaultNotesEventStream.shared,
         notesCommandFactory: NotesCommandFactory) {
        self.note = note
        super.init(repository: repository, notesCommandFactory: notesCommandFactory)
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
            repository.sendNoteUpdate(note)
        } catch {
            await set(state: .error(message: error.localizedDescription))
        }
    }
    
}

// MARK: - Setup
private extension UpdateViewModel {
    
    func setupText() {
        text = [note.title, note.body]
            .joined(separator: "\n")
    }
    
}
