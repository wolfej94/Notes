//
//  ListCoordinator.swift
//  NotesMVVM
//
//  Created by James Wolfe on 12/02/2025.
//

import NotesStorage
import SwiftUI

struct ListCoordinator: View {
    
    @State var showCreate = false
    @State var selectedNote: NoteViewModel?
    let commandFactory: NotesCommandFactory
    
    init(showCreate: Bool = false,
         selectedNote: NoteViewModel? = nil,
         commandFactory: NotesCommandFactory = DefaultNotesCommandFactory()) {
        self.showCreate = showCreate
        self.selectedNote = selectedNote
        self.commandFactory = commandFactory
    }
    
    var body: some View {
        let viewModel = ListViewModel(notesCommandFactory: commandFactory, actionHandler: handleListAction(_:))
        NavigationStack {
            ListView(viewModel: viewModel)
                .navigationDestination(item: $selectedNote, destination: detailView(forNote:))
                .navigationDestination(isPresented: $showCreate, destination: { detailView(forNote: nil) })
        }
    }
    
    @ViewBuilder
    private func detailView(forNote note: NoteViewModel?) -> DetailCoordinator {
        DetailCoordinator(note: note, commandFactory: commandFactory)
    }
    
    private func handleListAction(_ action: ListViewAction) {
        switch action {
        case .createSelected:
            showCreate = true
        case .noteSelected(let note):
            selectedNote = note
        }
    }
}
