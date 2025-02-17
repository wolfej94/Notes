//
//  Untitled.swift
//  NotesMVVM
//
//  Created by James Wolfe on 11/02/2025.
//

import NotesStorage
@testable import NotesMVVM_C

final class MockNotesStorage: NotesStorageProtocol, @unchecked Sendable {
    
    private(set) var notes = [NoteViewModel]()
    
    var createCalled = false
    var createErrorToThrow: Error?
    func create(_ note: NoteViewModel) async throws {
        createCalled = true
        if let createErrorToThrow {
            throw createErrorToThrow
        }
        notes.append(note)
    }
    
    var readCalled = false
    var readErrorToThrow: Error?
    func read() throws -> [NoteViewModel] {
        readCalled = true
        if let readErrorToThrow {
            throw readErrorToThrow
        }
        return notes
    }
    
    var updateCalled = false
    var updateErrorToThrow: Error?
    func update(_ note: NoteViewModel) async throws {
        updateCalled = true
        if let updateErrorToThrow {
            throw updateErrorToThrow
        }
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index] = note
    }
    
    var deleteCalled = false
    var deleteErrorToThrow: Error?
    func delete(_ notes: [NoteViewModel]) async throws {
        deleteCalled = true
        if let deleteErrorToThrow {
            throw deleteErrorToThrow
        }
        let ids = notes.map { $0.id }
        self.notes.removeAll(where: { ids.contains($0.id) })
    }
    
}
