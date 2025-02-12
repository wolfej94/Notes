//
//  Command.swift
//  NotesMVVM
//
//  Created by James Wolfe on 10/02/2025.
//

protocol ThrowingCommand {
    associatedtype Response
    func execute() throws -> Response
}
