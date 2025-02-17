//
//  CreateViewModelTests.swift
//  NotesMVVM
//
//  Created by James Wolfe on 12/02/2025.
//


import Testing
import UIKit
import NotesStorage
@testable import NotesMVVM_C

@Suite("Create View Model")
final class CreateViewModelTests: @unchecked Sendable {
    
    let storage: MockNotesStorage
    let commandFactory: NotesCommandFactory
    let stream = DefaultNotesEventStream.shared
    var subject: CreateViewModel!
    
    init() {
        storage = MockNotesStorage()
        commandFactory = DefaultNotesCommandFactory(storage: storage)
        subject = CreateViewModel(
            repository: stream,
            notesCommandFactory: commandFactory
        )
    }
    
    @Test("Subject is editing on initialization")
    func subjectIsEditingOnInitialization() {
        #expect(subject.isEditing)
    }
    
    @Test("State is updated to error when storage throws on create")
    func stateIsUpdatedToErrorWhenStorageThrowsOnCreate() async {
        storage.createErrorToThrow = TestError.generic
        await subject.save()
        #expect(subject.state == .error(message: TestError.generic.localizedDescription))
    }
    
    @Test("Storage notes are updated on create")
    func storageNotesAreUpdatedOnCreate() async {
        #expect(storage.notes.isEmpty)
        subject.text = "Title\nBody\nMoreBody"
        await subject.save()
        #expect(storage.notes.first?.title == "Title")
        #expect(storage.notes.first?.body == "Body\nMoreBody")
    }
    
}

// MARK: - Test Data
extension CreateViewModelTests {
    
    struct TestData {
        static let notes = [NoteViewModel(id: UUID(), title: "Title", body: "Body")]
    }
    
    enum TestError: Error {
        case generic
    }
    
}
