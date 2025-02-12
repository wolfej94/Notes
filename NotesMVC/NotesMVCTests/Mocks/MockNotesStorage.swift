//
//  MockNotesStorage.swift
//  NotesMVC
//
//  Created by James Wolfe on 23/01/2025.
//

import NotesStorage
@testable import NotesMVC

final class MockNotesStorage: NotesStorageProtocol, @unchecked Sendable {
    
    private(set) var notes = [NoteViewModel]()
    
    var createCalled = false
    var createErrorToThrow: Error?
    var createCompletion: (() -> Void)?
    func create(_ note: NoteViewModel) async throws {
        defer { createCompletion?() }
        createCalled = true
        if let createErrorToThrow {
            throw createErrorToThrow
        }
        notes.append(note)
    }
    
    var readCalled = false
    var readErrorToThrow: Error?
    var readCompletion: (() -> Void)?
    func read() throws -> [NoteViewModel] {
        defer { readCompletion?() }
        readCalled = true
        if let readErrorToThrow {
            throw readErrorToThrow
        }
        return notes
    }
    var updateCalled = false
    var updateErrorToThrow: Error?
    var updateCompletion: (() -> Void)?
    func update(_ note: NoteViewModel) async throws {
        defer { updateCompletion?() }
        updateCalled = true
        if let updateErrorToThrow {
            throw updateErrorToThrow
        }
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index] = note
    }
    
    var deleteCalled = false
    var deleteErrorToThrow: Error?
    var deleteCompletion: (() -> Void)?
    func delete(_ notes: [NoteViewModel]) async throws {
        defer { deleteCompletion?() }
        deleteCalled = true
        if let deleteErrorToThrow {
            throw deleteErrorToThrow
        }
        let ids = notes.map { $0.id }
        self.notes.removeAll(where: { ids.contains($0.id) })
    }
    
}
