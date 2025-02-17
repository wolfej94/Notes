//
//  ViewModelTests.swift
//  NotesMVVM
//
//  Created by James Wolfe on 11/02/2025.
//

import Testing
@testable import NotesMVVM_C

@Suite("View Model")
struct ViewModelTests {
    
    let subject = ViewModel(state: .loaded)
    
    @MainActor
    @Test("Synchronous set state updates subject state",
          arguments: [
            (UIState.error(message: "Test"), true),
            (UIState.loaded, true),
            (UIState.loading, true),
            (UIState.error(message: "Test"), false),
            (UIState.loaded, false),
            (UIState.loading, false)
          ]
    )
    func synchronousSetStateUpdatesSubjectState(to state: UIState, animated: Bool) {
        #expect(subject.state == .loaded)
        subject.set(state: state, animated: animated)
        #expect(subject.state == state)
    }
    
    @Test("Asynchronous set state updates subject state",
          arguments: [
            (UIState.error(message: "Test"), true),
            (UIState.loaded, true),
            (UIState.loading, true),
            (UIState.error(message: "Test"), false),
            (UIState.loaded, false),
            (UIState.loading, false)
          ]
    )
    func asynchronousSetStateUpdatesSubjectState(to state: UIState, animated: Bool) async {
        #expect(subject.state == .loaded)
        await subject.set(state: state, animated: animated)
        #expect(subject.state == state)
    }
    
}
