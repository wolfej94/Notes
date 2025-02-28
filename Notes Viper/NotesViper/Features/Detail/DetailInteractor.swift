//
//  DetailInteractor.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//

import UIKit
import NotesStorage

protocol DetailInteractorProtocol: AnyObject {
    @MainActor func fetchNoteContent()
    @MainActor func saveNoteContent(_ text: String?) async
}

final class DetailInteractor: DetailInteractorProtocol {
    
    private let note: NoteViewModel?
    private let commandFactory: NotesCommandFactory
    weak var presenter: DetailInteractorOutputProtocol?
    
    init(note: NoteViewModel?,
         commandFactory: NotesCommandFactory = DefaultNotesCommandFactory()) {
        self.note = note
        self.commandFactory = commandFactory
    }
    
    func fetchNoteContent() {
        presenter?.didFetchNoteContent(title: note?.title ?? "", body: note?.body ?? "")
    }
    
    func saveNoteContent(_ text: String?) async {
        guard let text = text, !text.isEmpty else { return }
        let (title, body) = titleAndBody(ofText: text)
        do {
            if var note {
                note.title = title
                note.body = body
                let command = commandFactory.updateCommand(note: note)
                try await command.execute()
            } else {
                let note = NoteViewModel(id: UUID(), title: title, body: body)
                let command = commandFactory.addCommand(note: note)
                try await command.execute()
            }
        } catch {
            presenter?.didFailToSave(error)
        }
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
