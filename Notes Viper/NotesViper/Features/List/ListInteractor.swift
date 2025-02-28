//
//  ListInteractor.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//

import UIKit
import NotesStorage

protocol ListInteractorProtocol: AnyObject {
    @MainActor func fetchNotes(query: String?) throws
    func delete(note: NoteViewModel) async throws
}

final class ListInteractor: ListInteractorProtocol {
    
    private let commandFactory: NotesCommandFactory
    private let storage: NotesStorageProtocol
    private var listenerTask: Task<Void, Never>?
    weak var presenter: ListPresenterProtocol?
    
    init(commandFacotry: NotesCommandFactory = DefaultNotesCommandFactory(),
         storage: NotesStorageProtocol = NotesStorage.shared) {
        self.commandFactory = commandFacotry
        self.storage = storage
        self.listenForNotesEvents()
    }
    
    deinit {
        listenerTask?.cancel()
    }
    
    func fetchNotes(query: String?) throws {
        let notes = try commandFactory.readCommand().execute()
        let filteredNotes = commandFactory.filterNotesCommand(query: query ?? "", notes: notes).execute()
        presenter?.set(notes: filteredNotes)
    }
    
    func delete(note: NoteViewModel) async throws {
        try await commandFactory.deleteCommand(notes: [note]).execute()
    }
    
}

// MARK: - Helpers
private extension ListInteractor {
    
    func listenForNotesEvents() {
        listenerTask = storage.subscribeToEvents(onEvent: { [weak self] note in
            guard let self = self else { return }
            self.presenter?.refreshNotes()
        })
    }
    
}
