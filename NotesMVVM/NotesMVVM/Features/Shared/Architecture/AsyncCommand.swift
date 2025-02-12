//
//  AsyncCommand.swift
//  NotesMVVM
//
//  Created by James Wolfe on 10/02/2025.
//

protocol AsyncCommand {
    associatedtype Response
    func execute() async throws -> Response
}
