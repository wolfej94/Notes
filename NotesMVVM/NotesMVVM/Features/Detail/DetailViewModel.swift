//
//  DetailViewModel.swift
//  NotesMVVM
//
//  Created by James Wolfe on 31/01/2025.
//

import NotesStorage
import SwiftUI

final class DetailViewModel: ViewModel, ObservableObject {
    
    // MARK: - Data
    private var note: NoteViewModel?
    @Binding private var notes: Set<NoteViewModel>
    
    let notesCommandFactory: NotesCommandFactory
    @Published var isEditing: Bool
    @Published var text = ""
    
    // MARK: - Initialization
    init(note: NoteViewModel?,
         notes: Binding<Set<NoteViewModel>>,
         notesCommandFactory: NotesCommandFactory) {
        _notes = notes
        self.note = note
        self.notesCommandFactory = notesCommandFactory
        self.isEditing = true
        super.init(state: .loaded)
        setupText()
    }
    
}

// MARK: - Setup
private extension DetailViewModel {
    
    func setupText() {
        text = [note?.title, note?.body]
            .compactMap { $0 }
            .joined(separator: "\n")
    }
    
}

// MARK: - Actions
extension DetailViewModel {
    
    public func save() async {
        switch self.note == nil {
        case true:
            await self.createNote()
        case false:
            await self.updateNote()
        }
    }
    
    @MainActor
    private func createNote() async {
        let (title, body) = titleAndBody(ofText: text)
        let note = NoteViewModel(id: UUID(), title: title, body: body)
        do {
            try await notesCommandFactory
                .addCommand(note: note)
                .execute()
            notes.insert(note)
            self.note = note
        } catch {
            await set(state: .error(message: error.localizedDescription))
        }
    }
    
    @MainActor
    private func updateNote() async {
        guard var note else { return }
        notes.remove(note)
        let (title, body) = titleAndBody(ofText: text)
        note.title = title
        note.body = body
        do {
            try await notesCommandFactory
                .updateCommand(note: note)
                .execute()
            self.note = note
        } catch {
            await set(state: .error(message: error.localizedDescription))
        }
        notes.insert(note)
    }
    
}

// MARK: Helpers
private extension DetailViewModel {
    
    func titleAndBody(ofText text: String) -> (title: String, body: String) {
        let titleAndBody = text.split(separator: "\n", maxSplits: 1)
        let title = String(titleAndBody.first ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let body = String(titleAndBody.last ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (title: title, body: body)
    }
    
}
