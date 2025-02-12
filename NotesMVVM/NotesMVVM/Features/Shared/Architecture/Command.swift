//
//  Command.swift
//  NotesMVVM
//
//  Created by James Wolfe on 12/02/2025.
//

protocol Command {
    associatedtype Response
    func execute() -> Response
}

