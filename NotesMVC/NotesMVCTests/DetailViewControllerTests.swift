//
//  DetailViewControllerTests.swift
//  DetailViewControllerTests
//
//  Created by James Wolfe on 23/01/2025.
//
//  This test suite is designed for a view controller using a pure MVC architecture. While MVC is widely used,
//  it has certain limitations, especially in testing and UI-logic separation.
//
//  **Challenges of Pure MVC:**
//
//  1. **Tight Coupling Between UI and Logic**: The view controller manages both UI updates and business logic,
//     making it difficult to test the logic without triggering UI changes or requiring the full UI to be set up.
//
//  2. **Lack of Abstraction**: In MVC, the business logic is often directly handled by the controller, with little
//     abstraction. This makes the code less modular and harder to test in isolation compared to modern patterns like
//     MVVM or VIPER, which separate logic from the UI.
//
//  3. **Hacky Test Setup**: To work around MVC’s limitations, some test methods rely on unconventional approaches,
//     such as manually invoking UI events or using continuations to simulate async behavior. These workarounds
//     are necessary due to the lack of proper abstraction, as internal UI-related methods are tested alongside business
//     logic.
//
//  While these tests are functional, they may appear hacky due to the inherent limitations of the MVC pattern.
//

import XCTest
import NotesStorage
import NotesUI
@testable import NotesMVC

@MainActor
final class DetailViewControllerTests: XCTestCase {
    
    private var delegate: MockDetailViewControllerDelegate!
    
    override func setUp() {
        super.setUp()
        delegate = MockDetailViewControllerDelegate()
    }
    
    // MARK: - Helper Methods
    private func makeDetailViewController(note: NoteViewModel?) async -> DetailViewController {
        let viewController = DetailViewController(note: note)
        viewController.delegate = delegate
        viewController.loadViewIfNeeded()
        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()
        return viewController
    }
    
    func testDelegateIsCalledWhenCreatingNote() async {
        let subject = await makeDetailViewController(note: nil)
        subject.editorField.text = "Title\nBody"
        subject.beginAppearanceTransition(false, animated: false)
        subject.endAppearanceTransition()
        XCTAssertEqual(delegate.noteToCreate?.title, "Title")
        XCTAssertEqual(delegate.noteToCreate?.body, "Body")
    }
    
    func testDelegateIsCalledWhenUpdatingNote() async {
        let subject = await makeDetailViewController(note: TestData.note)
        subject.editorField.text = "Title\nBody"
        subject.beginAppearanceTransition(false, animated: false)
        subject.endAppearanceTransition()
        XCTAssertEqual(delegate.noteToUpdate?.title, "Title")
        XCTAssertEqual(delegate.noteToUpdate?.body, "Body")
    }
    
    func testDelegateIsNotCalledWhenUpdatingNoteWithEmptyText() async {
        let subject = await makeDetailViewController(note: TestData.note)
        subject.editorField.text = ""
        subject.beginAppearanceTransition(false, animated: false)
        subject.endAppearanceTransition()
        XCTAssertNil(delegate.noteToUpdate?.title)
        XCTAssertNil(delegate.noteToUpdate?.body)
    }
    
    func testDelegateIsNotCalledWhenCreatingNoteWithEmptyText() async {
        let subject = await makeDetailViewController(note: TestData.note)
        subject.editorField.text = ""
        subject.beginAppearanceTransition(false, animated: false)
        subject.endAppearanceTransition()
        XCTAssertNil(delegate.noteToUpdate?.title)
        XCTAssertNil(delegate.noteToUpdate?.body)
    }
    
}

private extension DetailViewControllerTests {
    struct TestData {
        static let note: NoteViewModel = NoteViewModel(id: UUID(), title: "", body: "")
    }
}
