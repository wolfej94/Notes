//
//  ReadNotesCommand.swift
//  NotesMVVM
//
//  Created by James Wolfe on 10/02/2025.
//

import NotesStorage

struct ReadNotesCommand: ThrowingCommand {
    
    let storage: NotesStorageProtocol
    
    func execute() throws -> Set<NoteViewModel> {
        try Set(storage.read())
    }
}
