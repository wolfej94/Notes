//
//  ListPresenter.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//
import UIKit
import NotesStorage

protocol ListPresenterProtocol: AnyObject {
    @MainActor func refreshNotes()
    @MainActor func searchNotes(with text: String)
    @MainActor func deleteNote(at index: Int) async
    @MainActor func set(notes: [NoteViewModel])
    @MainActor func editButtonTapped()
    func addButtonTapped()
    func noteCount() -> Int
    func noteTapped(at index: Int)
    func note(at index: Int) -> NoteViewModel?
}

final class ListPresenter: ListPresenterProtocol {
    
    weak var view: ListViewProtocol?
    private var interactor: ListInteractorProtocol
    private var router: ListRouterProtocol
    private var notes = [NoteViewModel]()
    private var isEditing = false
    
    init(view: ListViewProtocol,
         interactor: ListInteractorProtocol,
         router: ListRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func noteCount() -> Int {
        return notes.count
    }
    
    func note(at index: Int) -> NoteViewModel? {
        guard notes.indices.contains(index) else { return nil }
        return notes[index]
    }
    
    func noteTapped(at index: Int) {
        guard let note = note(at: index) else { return }
        router.navigateToDetail(note: note)
    }
    
    func addButtonTapped() {
        router.navigateToDetail(note: nil)
    }
    
    func editButtonTapped() {
        isEditing.toggle()
        view?.reload(isEditing: isEditing)
    }
    
    func set(notes: [NoteViewModel]) {
        self.notes = notes
        updateNoteCount()
        view?.reload(isEditing: isEditing)
    }
    
    func refreshNotes() {
        do {
            try interactor.fetchNotes(query: nil)
        } catch {
            view?.present(error: error)
        }
    }
    
    func deleteNote(at index: Int) async {
        do {
            guard notes.indices.contains(index) else { return }
            let note = notes[index]
            try await interactor.delete(note: note)
            notes.remove(at: index)
            self.updateNoteCount()
        } catch {
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.view?.present(error: error)
            }
        }
    }
    
    func searchNotes(with text: String) {
        do {
            try interactor.fetchNotes(query: text)
        } catch {
            view?.present(error: error)
        }
    }
    
}

// MARK: - Helpers
private extension ListPresenter {
    
    @MainActor
    func updateNoteCount() {
        let noteCountText = self.notes.isEmpty ? "No Notes" : "\(self.notes.count) Notes"
        view?.updateNoteCount(noteCountText)
    }
    
}
