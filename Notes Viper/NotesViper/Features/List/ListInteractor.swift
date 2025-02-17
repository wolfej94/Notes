//
//  ListInteractor.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//

import UIKit
import NotesStorage

protocol ListInteractorProtocol: AnyObject {
    func fetchNotes() throws
    func createNote(withText text: String) async throws -> NoteViewModel
    func update(note: NoteViewModel, withText text: String) async throws
    func delete(note: NoteViewModel) async throws
}

final class ListInteractor: ListInteractorProtocol {
    
    private let storage: NotesStorageProtocol
    weak var presenter: ListPresenterProtocol?
    
    init(storage: NotesStorageProtocol) {
        self.storage = storage
    }
    
    func fetchNotes() throws {
        try presenter?.set(notes: storage.read())
    }
    
    func delete(note: NoteViewModel) async throws {
        try await storage.delete([note])
    }
    
    func createNote(withText text: String) async throws -> NoteViewModel {
        let (title, body) = titleAndBody(ofText: text)
        let note = NoteViewModel(id: UUID(), title: title, body: body)
        try await storage.create(note)
        return note
    }
    
    func update(note: NoteViewModel, withText text: String) async throws {
        let (title, body) = titleAndBody(ofText: text)
        var note = note
        note.title = title
        note.body = body
        try await storage.update(note)
    }
    
    private func titleAndBody(ofText text: String) -> (title: String, body: String) {
        let titleAndBody = text.split(separator: "\n", maxSplits: 1)
        let title = String(titleAndBody.first ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let body = String(titleAndBody.last ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (title: title, body: body)
    }
    
}
