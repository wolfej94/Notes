//
//  ListViewControllerTests.swift
//  ListViewControllerTests
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
@testable import NotesViper

@MainActor
final class ListViewControllerTests: XCTestCase {

    private var window: UIWindow!
    private var storage: MockNotesStorage!

    override func setUp() {
        super.setUp()
        storage = MockNotesStorage()
    }

    // MARK: - Helper Methods
    private func makeListViewController(navigationController: UINavigationController? = nil) async -> ListViewController {
        window = UIWindow()
        let viewController = ListViewController(storage: storage)
        if let navigationController {
            navigationController.setViewControllers([viewController], animated: false)
        }
        viewController.loadViewIfNeeded()
        window.rootViewController = viewController.navigationController ?? viewController
        window.makeKeyAndVisible()
        viewController.beginAppearanceTransition(true, animated: true)
        viewController.endAppearanceTransition()
        await withCheckedContinuation { continuation in
            storage.readCompletion = {
                continuation.resume()
            }
        }
        return viewController
    }
    
    private func waitForDelete(actionHandler: UIContextualAction.Handler) async {
        await withCheckedContinuation { continuation in
            storage.deleteCompletion = {
                continuation.resume()
            }
            actionHandler(UIContextualAction(), UIView()) { _ in }
        }
    }
    
    private func waitForCreate(createAction: () -> Void) async {
        await withCheckedContinuation { continuation in
            storage.createCompletion = {
                continuation.resume()
            }
            createAction()
        }
    }
    
    private func waitForUpdate(updateAction: () -> Void) async {
        await withCheckedContinuation { continuation in
            storage.updateCompletion = {
                continuation.resume()
            }
            updateAction()
        }
    }
}

// MARK: - UI Tests
extension ListViewControllerTests {
    
    func testCreatingNoteWithoutError() async {
        let subject = await makeListViewController()
        XCTAssertFalse(storage.createCalled)
        await waitForCreate(createAction: {
            subject.detailViewController(dismissedNote: nil, withText: "New Note")
        })
        XCTAssertTrue(storage.createCalled)
        XCTAssertEqual(storage.notes.first?.title, "New Note")
        XCTAssertNil(subject.alertController)
   }
       
   func testCreatingNoteWithError() async {
       storage.createErrorToThrow = TestData.Error.generic
       let subject = await makeListViewController()
       XCTAssertFalse(storage.createCalled)
       await waitForCreate(createAction: {
           subject.detailViewController(dismissedNote: nil, withText: "New Note")
       })
       XCTAssertTrue(storage.createCalled)
       XCTAssertNotNil(subject.alertController)
   }
       
   func testUpdatingNoteWithoutError() async throws {
       try await storage.create(TestData.note(title: "Title", body: "Body"))
       let subject = await makeListViewController()
       XCTAssertFalse(storage.updateCalled)
       await waitForUpdate(updateAction: {
           subject.detailViewController(dismissedNote: storage.notes.first, withText: "New Note")
       })
       XCTAssertTrue(storage.updateCalled)
       XCTAssertEqual(storage.notes.first?.title, "New Note")
       XCTAssertNil(subject.alertController)
   }
   
    func testUpdatingNoteWithError() async throws {
        storage.updateErrorToThrow = TestData.Error.generic
        try await storage.create(TestData.note(title: "Title", body: "Body"))
        let subject = await makeListViewController()
        XCTAssertFalse(storage.updateCalled)
        await waitForUpdate(updateAction: {
            subject.detailViewController(dismissedNote: storage.notes.first, withText: "New Note")
        })
        XCTAssertTrue(storage.updateCalled)
        XCTAssertNotNil(subject.alertController)
    }
    
    func testDeleteNoteWithoutError() async throws {
        try await storage.create(TestData.note())
        storage.deleteErrorToThrow = nil
        
        let subject = await makeListViewController()
        let indexPath = IndexPath(row: 0, section: 0)
        let swipeAction = try XCTUnwrap(subject.trailingSwipeAction(for: indexPath))
        await waitForDelete(actionHandler: swipeAction.handler)
        
        XCTAssert(storage.deleteCalled)
        XCTAssertNil(subject.alertController)
    }
    
    func testDeleteNoteWithError() async throws {
        try await storage.create(TestData.note())
        storage.deleteErrorToThrow = TestData.Error.generic
        let subject = await makeListViewController()

        let indexPath = IndexPath(row: 0, section: 0)
        let swipeAction = try XCTUnwrap(subject.trailingSwipeAction(for: indexPath))
        await waitForDelete(actionHandler: swipeAction.handler)

        XCTAssert(storage.deleteCalled)
        XCTAssertNotNil(subject.alertController)
    }
    
    func testFetchNotesWithoutError() async throws {
        storage.readErrorToThrow = nil
        let subject = await makeListViewController()
        XCTAssert(storage.readCalled)
        XCTAssertNil(subject.alertController)
    }
    
    func testFetchNotesWithError() async throws {
        storage.readErrorToThrow = TestData.Error.generic
        let subject = await makeListViewController()
        XCTAssert(storage.readCalled)
        XCTAssertNotNil(subject.alertController)
    }

    func testToolbarNoteCountLabelWithNotes() async throws {
        try await storage.create(TestData.note())
        let subject = await makeListViewController()

        XCTAssertEqual(subject.noteCountLabel.title, "1 Notes")
    }

    func testToolbarNoteCountLabelWithoutNotes() async {
        let subject = await makeListViewController()

        XCTAssertEqual(subject.noteCountLabel.title, "No Notes")
    }
    
    func testSearchUpdatesNoteCountLabel() async throws {
        try await storage.create(TestData.note(title: "Test 1", body: "Test 2"))
        try await storage.create(TestData.note(title: "Test 3", body: "Test 4"))
        
        let subject = await makeListViewController()
        
        XCTAssertEqual(subject.noteCountLabel.title, "2 Notes")
        
        try await subject.performSearch(text: "1")
        XCTAssertEqual(subject.noteCountLabel.title, "1 Notes")
        
        try await subject.performSearch(text: "3")
        XCTAssertEqual(subject.noteCountLabel.title, "1 Notes")
        
        try await subject.performSearch(text: "5")
        XCTAssertEqual(subject.noteCountLabel.title, "No Notes")
    }
    
    func testNavigationOnNoteSelection() async throws {
        try await storage.create(TestData.note())

        let navigationController = UINavigationController()
        let subject = await makeListViewController(navigationController: navigationController)

        XCTAssertEqual(subject.numberOfSections(in: subject.tableView), 1)
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(navigationController.viewControllers.count, 1)

        subject.tableView(subject.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertTrue(navigationController.viewControllers.last is DetailViewController)
    }
    
    func testNavigationOnAddingNote() async throws {
        try await storage.create(TestData.note())
        
        let navigationController = UINavigationController()
        let subject = await makeListViewController(navigationController: navigationController)
        
        XCTAssertEqual(subject.numberOfSections(in: subject.tableView), 1)
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        if let target = subject.addButton.target, let action = subject.addButton.action {
            _ = target.perform(action, with: subject.addButton)
            XCTAssertEqual(navigationController.viewControllers.count, 2)
            XCTAssertTrue(navigationController.viewControllers.last is DetailViewController)
        } else {
            XCTFail("Add button has no valid target and/or action")
        }
    }
    
    func testEditingModeToggling() async throws {
        try await storage.create(TestData.note())
        
        let navigationController = UINavigationController()
        let subject = await makeListViewController(navigationController: navigationController)
        
        XCTAssertTrue(subject.tableView.isEditing == false)
        XCTAssertEqual(subject.editButton.title, "Edit")
        if let target = subject.editButton.target, let action = subject.editButton.action {
            _ = target.perform(action, with: subject.editButton)
            XCTAssertTrue(subject.tableView.isEditing == true)
            XCTAssertEqual(subject.editButton.title, "Done")
            _ = target.perform(action, with: subject.editButton)
            XCTAssertTrue(subject.tableView.isEditing == false)
            XCTAssertEqual(subject.editButton.title, "Edit")
        } else {
            XCTFail("Edit button has no valid target and/or action")
        }
    }
    
}

// MARK: - Logic Tests
extension ListViewControllerTests {
    
    func testCellCountAfterNoteCreation() async throws {
        try await storage.create(TestData.note())
        let subject = await makeListViewController()

        XCTAssertEqual(subject.numberOfSections(in: subject.tableView), 1)
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 1)
    }
    
    func testCellCountAfterNoteDeletion() async throws {
        try await storage.create(TestData.note())
        let subject = await makeListViewController()
        
        XCTAssertEqual(subject.numberOfSections(in: subject.tableView), 1)
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 1)

        let indexPath = IndexPath(row: 0, section: 0)
        let swipeAction = try XCTUnwrap(subject.trailingSwipeAction(for: indexPath))
        await waitForDelete(actionHandler: swipeAction.handler)
        
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 0)
    }
    
    func testSearchUpdatesCellCount() async throws {
        try await storage.create(TestData.note(title: "Test 1", body: "Test 2"))
        try await storage.create(TestData.note(title: "Test 3", body: "Test 4"))

        let subject = await makeListViewController()

        XCTAssertEqual(subject.numberOfSections(in: subject.tableView), 1)
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 2)

        try await subject.performSearch(text: "1")
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 1)

        try await subject.performSearch(text: "3")
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 1)

        try await subject.performSearch(text: "5")
        XCTAssertEqual(subject.tableView(subject.tableView, numberOfRowsInSection: 0), 0)
    }
    
}

// MARK: - Subject Helper Methods
private extension ListViewController {
    var alertController: UIAlertController? {
        return presentedViewController as? UIAlertController
    }

    func performSearch(text: String) async throws {
        searchField.text = text
        try await Task.sleep(for: .seconds(0.3)) // Wait for timer delay on searches to end
    }

    func trailingSwipeAction(for indexPath: IndexPath) -> UIContextualAction? {
        return tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)?.actions.first
    }
}

// MARK: - Test Data
private extension ListViewControllerTests {
    struct TestData {
        static func note(title: String = "", body: String = "") -> NoteViewModel {
            NoteViewModel(id: UUID(), title: title, body: body)
        }
        
        enum Error: LocalizedError {
            case generic
        }
    }
}
