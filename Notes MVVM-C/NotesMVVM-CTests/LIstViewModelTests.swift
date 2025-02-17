//
//  LIstViewModelTests.swift
//  NotesMVVM
//
//  Created by James Wolfe on 11/02/2025.
//

import Testing
import NotesStorage
import UIKit
@testable import NotesMVVM_C

@Suite("List View Model")
struct ListViewModelTests {
    
    let storage: MockNotesStorage
    let commandFactory: DefaultNotesCommandFactory
    let subject: ListViewModel
    
    init() {
        storage = MockNotesStorage()
        commandFactory = DefaultNotesCommandFactory(storage: storage)
        subject = ListViewModel(notesCommandFactory: commandFactory, actionHandler: { _ in })
    }
    
    @Test("Subject refreshes on initialization")
    func subjectRefreshesOnInitialization() {
        let storage = MockNotesStorage()
        let commandFactory = DefaultNotesCommandFactory(storage: storage)
        let subject = ListViewModel(notesCommandFactory: commandFactory, actionHandler: { _ in })
        #expect(storage.readCalled == true)
        #expect(subject.state == .loaded)
    }
    
    @Test("Error state is set when storage throws on refresh")
    func errorStateIsSetWhenStorageThrowsOnRefresh() {
        #expect(subject.state == .loaded)
        storage.readErrorToThrow = TestError.generic
        subject.refresh()
        #expect(subject.state == .error(message: TestError.generic.localizedDescription))
    }
    
    @Test("Query is cleared when subject refreshes")
    func queryIsClearedWhenSubjectRefreshes() {
        subject.query = "Test"
        subject.refresh()
        #expect(subject.query.isEmpty)
    }
    
    @MainActor
    @Test("Notes are set correctly when subject refreshes")
    func notesAreSetCorrectlyWhenSubjectRefreshes() async throws {
        try await populateNotes(withNotes: [TestData.notes[0]])
        #expect(subject.notes.count == 1)
        #expect(subject.notes.first == TestData.notes[0])
    }
    
    @MainActor
    @Test("Notes count label text set correctly when subject refreshes",
          arguments: [
            [TestData.notes[0]],
            TestData.notes,
            []
          ]
    )
    func notesLabelTextAreSetCorrectlyWhenSubjectRefreshes(notes: [NoteViewModel]) async throws {
        try await populateNotes(withNotes: notes)
        let notes = subject.filteredNotes()
        await MainActor.run {
            #expect(notes.count == notes.count)
            switch notes.count {
            case 0:
                #expect(subject.noteCountLabelText == "0 notes")
            case 1:
                #expect(subject.noteCountLabelText == "1 note")
            case 2:
                #expect(subject.noteCountLabelText == "2 notes")
            default:
                Issue.record("Invalid notes count: value should be 0, 1 or 2")
            }
        }
    }
    
    @Test("Delete updates notes in storage correctly")
    func deleteUpdatesNotesInStorageCorrectly() async throws {
        try await populateNotes()
        await subject.delete(at: .init(integer: 0))
        #expect(storage.deleteCalled)
        #expect(storage.notes.count == 1)
        #expect(subject.filteredNotes().count == 1)
    }
    
    @Test("Delete updates subject state to error when storage throws")
    func deleteUpdatesSubjecStateToErrorWhenStorageThrows() async throws {
        try await populateNotes()
        storage.deleteErrorToThrow = TestError.generic
        await subject.delete(at: .init(integer: 0))
        #expect(subject.filteredNotes().count == 2)
        #expect(subject.state == .error(message: TestError.generic.localizedDescription))
    }
    
    @Test("Query filters notes correctly",
          arguments: [
            ("1", 1),
            ("2", 1),
            ("0", 0)
          ]
    )
    func queryFiltersNotesCorrectly(query: String, expectedCount: Int) async throws {
        try await populateNotes()
        subject.query = query
        let notes = subject.filteredNotes()
        #expect(notes.count == expectedCount)
    }
    
    @Test("Subject notes are sorted by updated at ascending")
    func subjectNotesAreSortedByUpdatedAtAscending() async throws {
        try await populateNotes()
        storage.deleteErrorToThrow = TestError.generic
        await subject.delete(at: .init(integer: 0))
        let sortedNotes = subject.notes.sorted { lhs, rhs in
            guard let lhsUpdatedAt = lhs.updatedAt, let rhsUpdatedAt = rhs.updatedAt else { return false }
            return lhsUpdatedAt > rhsUpdatedAt
        }
        #expect(subject.filteredNotes() == sortedNotes)
        #expect(subject.state == .error(message: TestError.generic.localizedDescription))
    }
    
    @Test("Action handler is called correctly on note selection")
    func actionHandlerIsCalledCorrectlyOnNoteSelection() {
        var selectedNote: NoteViewModel?
        let subject = ListViewModel(notesCommandFactory: commandFactory) { action in
            switch action {
            case .noteSelected(let note):
                selectedNote = note
            case .createSelected:
                break
            }
        }
        subject.selectNote(note: TestData.notes[0])
        #expect(selectedNote == TestData.notes[0])
    }
    
    @Test("Action handler is called correctly on note creation selected")
    func actionHandlerIsCalledCorrectlyOnNoteCreationSelected() {
        var noteCreationSelected = false
        let subject = ListViewModel(notesCommandFactory: commandFactory) { action in
            switch action {
            case .createSelected:
                noteCreationSelected = true
            case .noteSelected:
                break
            }
        }
        subject.selectCreate()
        #expect(noteCreationSelected == true)
    }
    
}

// MARK: - Helpers
extension ListViewModelTests {
    
    private func populateNotes(withNotes notes: [NoteViewModel] = TestData.notes) async throws {
        for note in notes {
            try await storage.create(note)
        }
        #expect(subject.notes.isEmpty)
        subject.refresh()
        #expect(subject.notes.count == notes.count)
    }
    
}

// MARK: - Test Data
extension ListViewModelTests {
    
    struct TestData {
        static let notes = [
            NoteViewModel(id: UUID(), title: "Title 1", body: "Body 1"),
            NoteViewModel(id: UUID(), title: "Title 2", body: "Body 2")
        ]
    }
    
    enum TestError: Error {
        case generic
    }
    
}
