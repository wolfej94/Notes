//
//  ListView.swift
//  NotesMVVM
//
//  Created by James Wolfe on 31/01/2025.
//

import SwiftUI
import NotesUI
import NotesStorage

struct ListView: View {
    
    @StateObject var viewModel: ListViewModel
    
    var body: some View {
        VStack(spacing: .zero) {
            searchView
            notesListView
        }
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .navigationTitle("Notes")
        .refreshable(action: { viewModel.refresh() })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Text("\(viewModel.noteCountLabelText)")
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    Button(
                        action: viewModel.selectCreate,
                        label: {
                            Image(systemName: "square.and.pencil")
                        }
                    )
                    .frame(width: 50)
                }
                .padding(.leading, 50)
            }
        }
        .animation(.easeInOut, value: viewModel.notes)
        .animation(.easeInOut, value: viewModel.query)
    }
    
    var searchView: some View {
        SearchField(placeholder: "Search", text: $viewModel.query, cancelButtonTitle: "Cancel", backgroundColor: .field)
    }
    
    var notesListView: some View {
        List {
            ForEach(viewModel.filteredNotes()) { note in
                Button(
                    action: { viewModel.selectNote(note: note) },
                    label: {
                        NoteCell(title: note.title,
                                 body: note.body,
                                 textColor: .text,
                                 backgroundColor: .field
                        )
                    }
                )
                .listRowBackground(Color.field)
                .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            }
            .onDelete { indexSet in
                Task { await viewModel.delete(at: indexSet) }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
    }

}

#Preview {
    NavigationStack {
        ListView(
            viewModel: .init(notesCommandFactory: DefaultNotesCommandFactory(),
                             actionHandler: { _ in }
                            )
        )
    }
}
