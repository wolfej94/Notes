//
//  ListViewModel.swift
//  NotesMVVM
//
//  Created by James Wolfe on 31/01/2025.
//

import NotesStorage
import SwiftUI

enum ListViewAction {
    typealias Handler = (Self) -> Void
    case noteSelected(note: NoteViewModel)
    case createSelected
}

final class ListViewModel: ViewModel, ObservableObject {
    
    // MARK: - Properties
    private let notesCommandFactory: NotesCommandFactory
    private let actionHandler: ListViewAction.Handler
    private let repository: NotesEventStream
    
    @Published public var query = ""
    @Published public var notes = Set<NoteViewModel>()
    @Published public var noteCountLabelText = ""
    
    // MARK: - Initializers
    init(notesCommandFactory: NotesCommandFactory,
         repository: NotesEventStream = DefaultNotesEventStream.shared,
         actionHandler: @escaping ListViewAction.Handler) {
        self.notesCommandFactory = notesCommandFactory
        self.actionHandler = actionHandler
        self.repository = repository
        super.init(state: .loading)
        subscribeToNotesStream()
        refresh()
    }
}

// MARK: - Setup
private extension ListViewModel {
    
    func subscribeToNotesStream() {
        Task {
            for await note in repository.noteStream {
                await MainActor.run {
                    _ = notes.update(with: note)
                }
            }
        }
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
                notes = Set(notesArray)
            }
        }
    }
    
    func filteredNotes() -> [NoteViewModel] {
        let result = notesCommandFactory
            .filterNotesCommand(query: query, notes: notes)
            .execute()
        Task {
            await MainActor.run {
                noteCountLabelText = "\(result.count) note\(result.count == 1 ? "" : "s")"
            }
        }
        return result
    }
    
    func selectNote(note: NoteViewModel) {
        actionHandler(.noteSelected(note: note))
    }
    
    func selectCreate() {
        actionHandler(.createSelected)
    }
    
}
