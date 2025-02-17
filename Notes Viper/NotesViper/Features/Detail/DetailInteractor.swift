//
//  DetailInteractor.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//

import UIKit
import NotesStorage

protocol DetailInteractorProtocol: AnyObject {
    func fetchNoteContent()
    func saveNoteContent(_ text: String?)
}

protocol DetailStorageProvider: AnyObject {
    func save(note: NoteViewModel?, withText text: String)
}

final class DetailInteractor: DetailInteractorProtocol {
    
    private let note: NoteViewModel?
    weak var presenter: DetailInteractorOutputProtocol?
    weak var storageProvider: DetailStorageProvider?
    
    init(note: NoteViewModel?, storageProvider: DetailStorageProvider?) {
        self.note = note
        self.storageProvider = storageProvider
    }
    
    func fetchNoteContent() {
        presenter?.didFetchNoteContent(title: note?.title ?? "", body: note?.body ?? "")
    }
    
    func saveNoteContent(_ text: String?) {
        guard let text = text, !text.isEmpty else { return }
        storageProvider?.save(note: note, withText: text)
    }
    
}
