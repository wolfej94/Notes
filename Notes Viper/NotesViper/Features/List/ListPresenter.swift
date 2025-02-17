//
//  ListPresenter.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//
import UIKit
import NotesStorage

protocol ListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func loadNotes()
    func addNoteTapped()
    func toggleEditing()
    func searchNotes(with text: String)
    func numberOfNotes() -> Int
    func didSelectNote(at index: Int)
    func note(at index: Int) -> NoteViewModel?
    func save(note: NoteViewModel?, withText text: String)
    func set(notes: [NoteViewModel])
    func deleteNote(at index: Int)
    var notes: [NoteViewModel] { get set }
}

final class ListPresenter: ListPresenterProtocol {
    
    weak var view: ListViewProtocol?
    var interactor: ListInteractorProtocol
    var router: ListRouterProtocol
    var notes: [NoteViewModel] = []
    private var filteredNotes: [NoteViewModel] = []
    
    init(view: ListViewProtocol, interactor: ListInteractorProtocol, router: ListRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewDidLoad() {
        loadNotes()
    }
    
    func set(notes: [NoteViewModel]) {
        self.notes = notes
        view?.clearSearchText()
    }
    
    func numberOfNotes() -> Int {
        return filteredNotes.count
    }
    
    func note(at index: Int) -> NoteViewModel? {
        guard filteredNotes.indices.contains(index) else { return nil }
        return filteredNotes[index]
    }
    
    func didSelectNote(at index: Int) {
        guard let note = note(at: index) else { return }
        router.navigateToDetail(note: note)
    }
    
    func addNoteTapped() {
        router.navigateToDetail(note: nil)
    }
    
    func toggleEditing() {
        view?.toggleEditing()
    }
    
    func loadNotes() {
        do {
            try interactor.fetchNotes()
            view?.reloadNotes()
            let noteCountText = filteredNotes.isEmpty ? "No Notes" : "\(filteredNotes.count) Notes"
            view?.updateNoteCount(noteCountText)
        } catch {
            view?.present(error: error)
        }
    }
    
    func save(note: NoteViewModel?, withText text: String) {
        Task { [weak self] in
            do {
                guard let self = self else { return }
                if let note {
                    try await self.interactor.update(note: note, withText: text)
                } else {
                    let note = try await self.interactor.createNote(withText: text)
                    await MainActor.run {
                        self.notes.append(note)
                        self.filteredNotes.append(note)
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.view?.present(error: error)
                }
            }
        }
    }
    
    func deleteNote(at index: Int) {
        guard filteredNotes.indices.contains(index) else { return }
        let note = filteredNotes[index]
        Task {
            do {
                try await interactor.delete(note: note)
                await MainActor.run { [weak self] in
                    self?.notes.removeAll { $0.id == note.id }
                    self?.filteredNotes.removeAll { $0.id == note.id }
                    self?.view?.removeNote(at: index)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.view?.present(error: error)
                }
            }
        }
    }
    
    func searchNotes(with text: String) {
        let query = text.lowercased()
        filteredNotes = notes.filter {
            guard !text.isEmpty else { return true }
            return $0.title.lowercased().contains(query) || $0.body.lowercased().contains(query)
        }
        view?.reloadNotes()
    }
    
}
