//
//  ListViewController.swift
//  NotesMVC
//
//  Created by James Wolfe on 20/01/2025.
//

import UIKit
import NotesStorage
import NotesUI

final class ListViewController: UIViewController {

    // MARK: - UI Elements
    lazy var searchField: UISearchField = {
        let field = UISearchField(placeholder: "Search",
                                  fieldBackgroundColor: .field,
                                  placeholderColor: .border,
                                  borderColor: .clear,
                                  textColor: .text)
        field.delegate = self
        field.heightAnchor.constraint(equalToConstant: 35).isActive = true
        return field
    }()

    lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINoteCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.backgroundColor = .clear
        return tableView
    }()

    lazy var noteCountLabel: UIBarButtonItem = {
        let label = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        label.tintColor = .text
        label.isEnabled = false
        return label
    }()

    lazy var addButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                        style: .done,
                        target: self,
                        action: #selector(addNoteTapped))
    }()
    
    lazy var editButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Edit",
                        style: .plain,
                        target: self,
                        action: #selector(editNotesTapped))
    }()

    // MARK: - Data
    private let storage: NotesStorageProtocol
    private var notes = [NoteViewModel]()
    private var filteredNotes = [NoteViewModel]()
    private var searchTimer: Timer?

    // MARK: - Initialization
    init(storage: NotesStorageProtocol = NotesStorage()) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
        title = "Notes"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .background
        view.addSubview(contentStack)
        contentStack.constrainToSuperviewSafeArea()
        
        contentStack.addArrangedSubview(searchField)
        contentStack.addArrangedSubview(tableView)
        
        setToolbarItems([
            UIBarButtonItem(systemItem: .flexibleSpace),
            noteCountLabel,
            UIBarButtonItem(systemItem: .flexibleSpace),
            addButton
        ], animated: false)
        
        navigationController?.setToolbarHidden(false, animated: false)
        navigationItem.rightBarButtonItem = editButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadNotesFromStorage()
    }
    
}

// MARK: - Data Loading
private extension ListViewController {
    
    func loadNotesFromStorage() {
        do {
            notes = try storage.read()
            filteredNotes = notes
            updateNoteCount()
            tableView.reloadSections([0], with: .automatic)
        } catch {
            present(error: error)
        }
    }
    
    func updateNoteCount() {
        let noteCountText = filteredNotes.isEmpty ? "No Notes" : "\(filteredNotes.count) Notes"
        noteCountLabel.title = noteCountText
    }
    
    @MainActor
    func delete(notes: [NoteViewModel]) async {
        let noteIDs = Set(notes.map { $0.id })
        let indexesToDelete = self.notes.enumerated().compactMap { index, note in
            noteIDs.contains(note.id) ? index : nil
        }

        guard !indexesToDelete.isEmpty else { return }

        do {
            try await storage.delete(notes)
            self.notes.remove(atOffsets: IndexSet(indexesToDelete))
            filter(NotesBy: searchField.text ?? "")
            let indexPaths = indexesToDelete.map { IndexPath(row: $0, section: 0) }
            tableView.deleteRows(at: indexPaths, with: .left)
            self.updateNoteCount()
        } catch {
            present(error: error)
        }
    }

    
    func note(forIndexPath indexPath: IndexPath) -> NoteViewModel? {
        guard filteredNotes.indices.contains(indexPath.row) else {
            return nil
        }
        return filteredNotes[indexPath.row]
    }
    
}

// MARK: - Actions
private extension ListViewController {
    
    @objc private func addNoteTapped() {
        let destination = DetailViewController(note: nil)
        destination.delegate = self
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc private func editNotesTapped() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            if self.tableView.isEditing {
                self.tableView.isEditing = false
            } else {
                self.tableView.isEditing = true
            }
            self.searchField.isHidden = self.tableView.isEditing == true
            self.searchField.alpha = self.tableView.isEditing == true ? .zero : 1
            self.navigationItem.rightBarButtonItem?.title = self.tableView.isEditing ? "Done" : "Edit"
        }
    }
    
    func noteTapped(_ note: NoteViewModel) {
        let destination = DetailViewController(note: note)
        destination.delegate = self
        navigationController?.pushViewController(destination, animated: true)
    }
    
}

// MARK: - UISearchFieldDelegate
extension ListViewController: UISearchFieldDelegate {

    func searchFieldEditingDidChange(_ searchText: String) {
        let substring = searchText.lowercased()
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.filter(NotesBy: substring)
            self.tableView.reloadSections([0], with: .automatic)
            updateNoteCount()
        }
    }

    private func filter(NotesBy substring: String) {
        filteredNotes = substring.isEmpty ? notes : notes.filter {
            $0.title.lowercased().contains(substring) || $0.body.lowercased().contains(substring)
        }
    }
}

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let note = note(forIndexPath: indexPath) else { return }
        noteTapped(note)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete",
                                              handler: { [weak self] _, _, _ in
            guard let note = self?.note(forIndexPath: indexPath) else { return }
            Task {
                await self?.delete(notes: [note])
            }
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as? UINoteCell else {
            return UITableViewCell()
        }
        guard let note = note(forIndexPath: indexPath) else {
            return cell
        }
        
        cell.title = note.title
        cell.body = note.body
        cell.backgroundColor = .field
        cell.textColor = .text
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - DetailViewControllerDelegate
extension ListViewController: DetailViewControllerDelegate {
    
    func detailViewController(dismissedNote note: NoteViewModel?, withText text: String) {
        Task {
            if let note {
                await update(note: note, withText: text)
            } else {
                await create(noteWithText: text)
            }
        }
    }
    
    @MainActor
    private func create(noteWithText text: String) async {
        let (title, body) = titleAndBody(ofText: text)
        let note = NoteViewModel(id: UUID(), title: title, body: body)
        do {
            try await storage.create(note)
        } catch {
            present(error: error)
        }
        notes.append(note)
        filter(NotesBy: searchField.text ?? "")
        let indexPath = IndexPath(row: filteredNotes.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .left)
        updateNoteCount()
    }
    
    @MainActor
    private func update(note: NoteViewModel, withText text: String) async {
        let (title, body) = titleAndBody(ofText: text)
        let note = NoteViewModel(id: note.id, title: title, body: body)
        do {
            try await storage.update(note)
        } catch {
            present(error: error)
        }
        guard let offset = filteredNotes.firstIndex(where: { $0.id == note.id }) else {
            loadNotesFromStorage()
            return
        }
        let indexPath = IndexPath(row: offset, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func titleAndBody(ofText text: String) -> (title: String, body: String) {
        let titleAndBody = text.split(separator: "\n", maxSplits: 1)
        let title = String(titleAndBody.first ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let body = String(titleAndBody.last ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (title: title, body: body)
    }
    
}

#Preview {
    UINavigationController(rootViewController: ListViewController())
}
