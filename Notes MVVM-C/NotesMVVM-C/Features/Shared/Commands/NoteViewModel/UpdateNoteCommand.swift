//
//  UpdateNoteCommand.swift
//  NotesMVVM
//
//  Created by James Wolfe on 10/02/2025.
//

import NotesStorage

struct UpdateNoteCommand: AsyncCommand {
    
    let note: NoteViewModel
    let storage: NotesStorageProtocol
    
    func execute() async throws {
        try await storage.update(note)
    }
}
