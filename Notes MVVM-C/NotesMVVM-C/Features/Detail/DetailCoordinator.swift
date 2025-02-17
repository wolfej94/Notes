//
//  DetailCoordinator.swift
//  NotesMVVM
//
//  Created by James Wolfe on 12/02/2025.
//

import NotesStorage
import SwiftUI

struct DetailCoordinator: View {
    
    let note: NoteViewModel?
    let commandFactory: NotesCommandFactory
    
    init(note: NoteViewModel?,
         commandFactory: NotesCommandFactory) {
        self.note = note
        self.commandFactory = commandFactory
    }
    
    var body: some View {
        if let note {
            let viewModel = UpdateViewModel(note: note,
                                            notesCommandFactory: commandFactory)
            DetailView(viewModel: viewModel)
        } else {
            let viewModel = CreateViewModel(notesCommandFactory: commandFactory)
            DetailView(viewModel: viewModel)
        }
        
        
    }
    
}
