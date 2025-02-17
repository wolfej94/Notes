//
//  DetailView.swift
//  NotesMVVM
//
//  Created by James Wolfe on 31/01/2025.
//

import SwiftUI
import NotesUI
import NotesStorage

struct DetailView: View {
    
    @StateObject var viewModel: DetailViewModel
    
    var body: some View {
        VStack {
            NoteEditor(text: $viewModel.text,
                       borderColor: .border,
                       backgroundColor: .field,
                       isEditing: $viewModel.isEditing)
                .padding()
        }
        .background {
            Color.background.ignoresSafeArea()
        }
        .onDisappear {
            Task { await viewModel.save() }
        }
    }
    
}

#Preview {
    NavigationStack {
        DetailView(viewModel: DetailViewModel(notesCommandFactory: DefaultNotesCommandFactory()))
    }
}
