//
//  ListViewModel.swift
//  NotesMVVM
//
//  Created by James Wolfe on 31/01/2025.
//

import NotesStorage
import SwiftUI

final class ListViewModel: ViewModel, ObservableObject {
    
    // MARK: - Properties
    let notesCommandFactory: NotesCommandFactory
    
    @Published public var query = ""
    @Published public var notes = Set<NoteViewModel>()
    public var noteCountLabelText = ""
    
    // MARK: - Initializers
    init(notesCommandFactory: NotesCommandFactory = DefaultNotesCommandFactory()) {
        self.notesCommandFactory = notesCommandFactory
        super.init(state: .loading)
        refresh()
    }
}

// MARK: - Actions
extension ListViewModel {
    
    func refresh() {
        do {
            query = ""
            notes = try notesCommandFactory
                .readCommand()
                .execute()
            set(state: .loaded)
        } catch {
            set(state: .error(message: error.localizedDescription))
        }
    }
    
    @MainActor
    func delete(at offsets: IndexSet) async {
        let notesArray = Array(filteredNotes())
        let deletedNotes = offsets.map { notesArray[$0] }
        notes.subtract(deletedNotes)
        
        do {
            try await notesCommandFactory
                .deleteCommand(notes: deletedNotes)
                .execute()
        } catch {
            await set(state: .error(message: error.localizedDescription))
            await MainActor.run {
                self.notes = Set(notesArray)
            }
        }
    }
    
    func filteredNotes() -> [NoteViewModel] {
        let result = notesCommandFactory
            .filterNotesCommand(query: query, notes: notes)
            .execute()
        noteCountLabelText = "\(result.count) note\(result.count == 1 ? "" : "s")"
        return result
    }
    
}
