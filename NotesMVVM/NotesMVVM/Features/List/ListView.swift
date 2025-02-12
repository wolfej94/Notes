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
    
    @StateObject var viewModel = ListViewModel()
    
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
                    NavigationLink(
                        destination: {
                            let viewModel = DetailViewModel(note: nil,
                                                            notes: $viewModel.notes,
                                                            notesCommandFactory: viewModel.notesCommandFactory)
                            DetailView(viewModel: viewModel)
                        },
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
                NavigationLink(value: note) {
                    NoteCell(title: note.title,
                             body: note.body,
                             textColor: .text,
                             backgroundColor: .field
                    )
                }
                .listRowBackground(Color.field)
                .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            }
            .onDelete { indexSet in
                Task { await viewModel.delete(at: indexSet) }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .navigationDestination(for: NoteViewModel.self) { note in
            let viewModel = DetailViewModel(note: note,
                                            notes: $viewModel.notes,
                                            notesCommandFactory: viewModel.notesCommandFactory)
            DetailView(viewModel: viewModel)
        }
    }

}

#Preview {
    NavigationStack {
        ListView()
    }
}
