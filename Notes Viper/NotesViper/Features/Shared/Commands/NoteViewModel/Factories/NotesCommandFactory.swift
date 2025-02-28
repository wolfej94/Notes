//
//  NotesCommandFactory.swift
//  NotesMVVM
//
//  Created by James Wolfe on 10/02/2025.
//

import NotesStorage

protocol NotesCommandFactory {
    func filterNotesCommand(query: String, notes: Set<NoteViewModel>) -> FilterNotesCommand
    func readCommand() -> ReadNotesCommand
    func addCommand(note: NoteViewModel) -> AddNoteCommand
    func updateCommand(note: NoteViewModel) -> UpdateNoteCommand
    func deleteCommand(notes: [NoteViewModel]) -> DeleteNotesCommand
}

final class DefaultNotesCommandFactory: NotesCommandFactory {
    
    private let storage: NotesStorageProtocol
    
    public init(storage: NotesStorageProtocol = NotesStorage.shared) {
        self.storage = storage
    }
    
    public func readCommand() -> ReadNotesCommand {
        ReadNotesCommand(storage: storage)
    }
    public func addCommand(note: NoteViewModel) -> AddNoteCommand {
        AddNoteCommand(note: note, storage: storage)
    }
    public func updateCommand(note: NoteViewModel) -> UpdateNoteCommand {
        UpdateNoteCommand(note: note, storage: storage)
    }
    
    public func deleteCommand(notes: [NoteViewModel]) -> DeleteNotesCommand {
        DeleteNotesCommand(notes: notes, storage: storage)
    }
    
    public func filterNotesCommand(query: String, notes: Set<NoteViewModel>) -> FilterNotesCommand {
        FilterNotesCommand(query: query, notes: notes)
    }
    
}
