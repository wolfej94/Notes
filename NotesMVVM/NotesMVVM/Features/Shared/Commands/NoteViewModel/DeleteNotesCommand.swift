//
//  DeleteNotesCommand.swift
//  NotesMVVM
//
//  Created by James Wolfe on 10/02/2025.
//

import NotesStorage

struct DeleteNotesCommand: AsyncCommand {
    
    let notes: [NoteViewModel]
    let storage: NotesStorageProtocol
    
    func execute() async throws {
        try await storage.delete(notes)
    }
}
