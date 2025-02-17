//
//  MockDetailViewControllerDelegate.swift
//  NotesViper
//
//  Created by James Wolfe on 25/01/2025.
//

import NotesStorage
import UIKit
@testable import NotesViper

final class MockDetailViewControllerDelegate: DetailViewControllerDelegate {
    
    var noteToUpdate: NoteViewModel?
    var noteToCreate: NoteViewModel?
    func detailViewController(dismissedNote note: NoteViewModel?, withText text: String) {
        let (title, body) = titleAndBody(fromText: text)
        if var note {
            note.title = title
            note.body = body
            noteToUpdate = note
        } else {
            noteToCreate = NoteViewModel(id: UUID(), title: title, body: body)
        }
    }
    
    private func titleAndBody(fromText text: String) -> (title: String, body: String) {
        let titleAndBody = text.split(separator: "\n", maxSplits: 1)
            .compactMap { String($0) }
        return (title: titleAndBody.first ?? "", body: titleAndBody.last ?? "")
    }
    
}
