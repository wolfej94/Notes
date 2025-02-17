//
//  NotesRepository.swift
//  NotesMVVM
//
//  Created by James Wolfe on 12/02/2025.
//

import NotesStorage
import Combine

protocol NotesEventStream {
    func sendNoteUpdate(_ note: NoteViewModel)
    var noteStream: AsyncStream<NoteViewModel> { get }
}

final class DefaultNotesEventStream: NotesEventStream {
    
    static let shared = DefaultNotesEventStream()
    
    private init() { }
    
    private var continuation: AsyncStream<NoteViewModel>.Continuation?
        
    lazy var noteStream: AsyncStream<NoteViewModel> = {
        return AsyncStream { continuation in
            self.continuation = continuation
        }
    }()

    func sendNoteUpdate(_ note: NoteViewModel) {
        continuation?.yield(note)
    }
}
