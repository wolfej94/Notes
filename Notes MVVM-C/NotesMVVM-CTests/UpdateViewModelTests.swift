//
//  UpdateViewModelTests.swift
//  NotesMVVM
//
//  Created by James Wolfe on 11/02/2025.
//

import Testing
import UIKit
import NotesStorage
@testable import NotesMVVM_C

@Suite("Update View Model")
final class UpdateViewModelTests: @unchecked Sendable {
    
    let storage: MockNotesStorage
    let commandFactory: NotesCommandFactory
    let stream = DefaultNotesEventStream.shared
    
    var subject: UpdateViewModel!
    
    init() {
        storage = MockNotesStorage()
        commandFactory = DefaultNotesCommandFactory(storage: storage)
    }
    
    @Test("Text is set correctly based on note content")
    func textIsSetCorrectlyBasedOnNoteContent() {
        let note = TestData.notes[0]
        let subject = UpdateViewModel(note: note, repository: stream, notesCommandFactory: commandFactory)
        #expect(subject.text == "\(note.title)\n\(note.body)")
    }
    
    @Test("Subject is editing on initialization")
    func subjectIsEditingOnInitialization() {
        let note = TestData.notes[0]
        let subject = UpdateViewModel(note: note, repository: stream, notesCommandFactory: commandFactory)
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
    
}

// MARK: - Helpers
private extension UpdateViewModelTests {
    
    func subjectWithNote() async throws -> UpdateViewModel {
        try await storage.create(TestData.notes[0])
        #expect(storage.notes.count == 1)
        return UpdateViewModel(
            note: TestData.notes[0],
            repository: stream,
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
