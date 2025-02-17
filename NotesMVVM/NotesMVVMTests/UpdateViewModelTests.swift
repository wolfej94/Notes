//
//  UpdateViewModelTests.swift
//  NotesMVVM
//
//  Created by James Wolfe on 11/02/2025.
//

import Testing
import UIKit
import NotesStorage
@testable import NotesMVVM

@Suite("Update View Model")
final class UpdateViewModelTests: @unchecked Sendable {
    
    var notes = Set<NoteViewModel>()
    let storage: MockNotesStorage
    let commandFactory: NotesCommandFactory
    
    init() {
        storage = MockNotesStorage()
        commandFactory = DefaultNotesCommandFactory(storage: storage)
    }
    
    @Test("Text is set correctly based on note content")
    func textIsSetCorrectlyBasedOnNoteContent() {
        let note = TestData.notes[0]
        let subject = UpdateViewModel(note: note, notes: .constant([]), notesCommandFactory: commandFactory)
        #expect(subject.text == "\(note.title)\n\(note.body)")
    }
    
    @Test("Subject is editing on initialization")
    func subjectIsEditingOnInitialization() {
        let subject = UpdateViewModel(note: TestData.notes[0], notes: .constant([]), notesCommandFactory: commandFactory)
        #expect(subject.isEditing)
    }
    
    @Test("State is updated to error when storage throws on update")
    func stateIsUpdatedToErrorWhenStorageThrowsOnUpdate() async throws {
        let subject = try await subjectWithNote()
        subject.text = "Title\nBody\nMoreBody"
        storage.updateErrorToThrow = TestError.generic
        await subject.save()
        #expect(subject.state == .error(message: TestError.generic.localizedDescription))
    }
    
    @Test("Storage notes are updated on update")
    func storageNotesAreUpdatedOnUpdate() async throws {
        let subject = try await subjectWithNote()
        
        #expect(storage.notes.first?.title == "Title")
        #expect(storage.notes.first?.body == "Body")
        subject.text = "Title2\nBody2"
        await subject.save()
        #expect(storage.notes.first?.title == "Title2")
        #expect(storage.notes.first?.body == "Body2")
        #expect(storage.notes.first?.id == TestData.notes[0].id)
    }
    
    @Test("Subject binding notes are updated on update")
    func subjectBindingNotesAreUpdatedOnUpdate() async throws {
        let subject = try await subjectWithNote()
        
        #expect(notes.first?.title == "Title")
        #expect(notes.first?.body == "Body")
        subject.text = "Title2\nBody2"
        await subject.save()
        #expect(self.notes.first?.title == "Title2")
        #expect(self.notes.first?.body == "Body2")
        #expect(notes.first?.id == TestData.notes[0].id)
    }
    
}

// MARK: - Helpers
private extension UpdateViewModelTests {
    
    func subjectWithNote() async throws -> DetailViewModel {
        notes = Set(TestData.notes)
        try await storage.create(TestData.notes[0])
        #expect(storage.notes.count == 1)
        #expect(notes.count == 1)
        return UpdateViewModel(
            note: TestData.notes[0],
            notes: .init(get: { self.notes }, set: { self.notes = $0 }),
            notesCommandFactory: commandFactory
        )
    }
    
}

// MARK: - Test Data
extension UpdateViewModelTests {
    
    struct TestData {
        static let notes = [NoteViewModel(id: UUID(), title: "Title", body: "Body")]
    }
    
    enum TestError: Error {
        case generic
    }
    
}
