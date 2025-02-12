//
//  FilterNotesCommand.swift
//  NotesMVVM
//
//  Created by James Wolfe on 10/02/2025.
//
import NotesStorage

struct FilterNotesCommand: Command {
    
    let query: String
    let notes: Set<NoteViewModel>
    
    func execute() -> [NoteViewModel] {
        let lowercasedQuery = query.lowercased()
        
        let filteredNotes = query.isEmpty ? Array(notes) : notes.filter { note in
            note.title.lowercased().contains(lowercasedQuery) || note.body.lowercased().contains(lowercasedQuery)
        }
        
        return filteredNotes.sorted { lhs, rhs in
            guard let lhsUpdatedAt = lhs.updatedAt, let rhsUpdatedAt = rhs.updatedAt else { return false }
            return lhsUpdatedAt > rhsUpdatedAt
        }
    }
}
