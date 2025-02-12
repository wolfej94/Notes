//
//  NoteStorage+CRUD.swift
//  NotesMVC
//
//  Created by James Wolfe on 22/01/2025.
//

import NotesStorage

internal protocol NotesStorageProtocol: Sendable {

    /// Creates a new note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to create.
    /// - Throws: An error if the creation fails.
    func create(_ note: NoteViewModel) async throws

    /// Reads all notes from storage.
    /// - Returns: An array of `NoteViewModel` instances.
    /// - Throws: An error if the read operation fails.
    func read() throws -> [NoteViewModel]

    /// Updates an existing note asynchronously.
    /// - Parameters:
    ///   - note: The `NoteViewModel` representing the note to update.
    /// - Throws: An error if the update fails.
    func update(_ note: NoteViewModel) async throws

    /// Deletes notes asynchronously.
    /// - Parameters:
    ///   - notes: An array of `NoteViewModel` instances to delete.
    /// - Throws: An error if the deletion fails.
    func delete(_ notes: [NoteViewModel]) async throws

}

extension NotesStorage: NotesStorageProtocol { }
