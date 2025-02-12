//
//  DetailViewModelTests.swift
//  NotesMVVM
//
//  Created by James Wolfe on 11/02/2025.
//

import Testing
import UIKit
import NotesStorage
@testable import NotesMVVM

@Suite("Detail View Model")
final class DetailViewModelTests: @unchecked Sendable {
    
    var notes = Set<NoteViewModel>()
    let storage: MockNotesStorage
    let commandFactory: NotesCommandFactory
    var subject: DetailViewModel!
    
    init() {
        storage = MockNotesStorage()
        commandFactory = DefaultNotesCommandFactory(storage: storage)
        subject = DetailViewModel(
            note: nil,
            notes: .init(get: { self.notes }, set: { self.notes = $0 }),
            notesCommandFactory: commandFactory
        )
    }
    
    @Test("Text is set correctly based on note content",
          arguments: [
            NoteViewModel(id: UUID(), title: "Title", body: "Body"),
            nil
          ]
    )
    func textIsSetCorrectlyBasedOnNoteContent(note: NoteViewModel?) {
        let subject = DetailViewModel(note: note, notes: .constant([]), notesCommandFactory: commandFactory)
        if let note {
            #expect(subject.text == "\(note.title)\n\(note.body)")
        } else {
            #expect(subject.text.isEmpty)
        }
    }
    
    @Test("Subject is editing on initialization")
    func subjectIsEditingOnInitialization() {
        #expect(subject.isEditing)
    }
    
    @Test("Create is called when subject note is nil")
    func createIsCalledWhenSubjectNoteIsNil() async {
        #expect(storage.createCalled == false)
        #expect(storage.notes.isEmpty)
        subject.text = "Title\nBody\nMoreBody"
        await subject.save()
        #expect(storage.createCalled)
        #expect(subject.state == .loaded)
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
    
    @Test("Subject binding notes are updated on create")
    func subjectBindingNotesAreUpdatedOnCreate() async {
        #expect(storage.notes.isEmpty)
        subject.text = "Title\nBody\nMoreBody"
        await subject.save()
        #expect(notes.first?.title == "Title")
        #expect(notes.first?.body == "Body\nMoreBody")
    }
    
    @Test("Update is called when subject note is not nil")
    func updateIsCalledWhenSubjectNoteIsNotNil() async throws {
        #expect(storage.updateCalled == false)
        let subject = try await subjectWithNote()
        subject.text = "Title\nBody\nMoreBody"
        await subject.save()
        #expect(storage.updateCalled == true)
        #expect(subject.state == .loaded)
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
private extension DetailViewModelTests {
    
    func subjectWithNote() async throws -> DetailViewModel {
        notes = Set(TestData.notes)
        try await storage.create(TestData.notes[0])
        #expect(storage.notes.count == 1)
        #expect(notes.count == 1)
        return DetailViewModel(
            note: TestData.notes[0],
            notes: .init(get: { self.notes }, set: { self.notes = $0 }),
            notesCommandFactory: commandFactory
        )
    }
    
}

// MARK: - Test Data
extension DetailViewModelTests {
    
    struct TestData {
        static let notes = [NoteViewModel(id: UUID(), title: "Title", body: "Body")]
    }
    
    enum TestError: Error {
        case generic
    }
    
}
