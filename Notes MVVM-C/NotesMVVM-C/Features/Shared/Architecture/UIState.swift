//
//  UIState.swift
//  NotesMVVM
//
//  Created by James Wolfe on 31/01/2025.
//

enum UIState: Equatable {
    case loading
    case loaded
    case error(message: String)
}
