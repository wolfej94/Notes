//
//  ListView.swift
//  NotesViper
//
//  Created by James Wolfe on 20/01/2025.
//
import UIKit
import NotesStorage
import NotesUI

protocol ListViewProtocol: UIViewController {
    @MainActor func reload(isEditing: Bool)
    @MainActor func updateNoteCount(_ countText: String)
    @MainActor func present(error: Error)
}

final class ListView: UIViewController {
    
    // MARK: - Properties
    var presenter: ListPresenterProtocol!
    
    // MARK: - UI Elements
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private lazy var searchField: UISearchField = {
        let field = UISearchField(placeholder: "Search", fieldBackgroundColor: .field, placeholderColor: .border, borderColor: .clear, textColor: .text)
        field.delegate = self
        field.heightAnchor.constraint(equalToConstant: 35).isActive = true
        return field
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINoteCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var noteCountLabel: UIBarButtonItem = {
        let label = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        label.tintColor = .text
        label.isEnabled = false
        return label
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(addButtonTapped))
    }()
    
    private lazy var editButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.refreshNotes()
    }
    
    // MARK: - Setup
    private func setup() {
        title = "Notes"
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
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        presenter.addButtonTapped()
        searchField.cancelEditing()
    }
    
    @objc private func editButtonTapped() {
        presenter.editButtonTapped()
    }
    
}

extension ListView: ListViewProtocol {
    
    func reload(isEditing: Bool) {
        tableView.isEditing = isEditing
        editButton.title = isEditing ? "Done" : "Edit"
        tableView.reloadSections([0], with: .automatic)
    }
    
    func updateNoteCount(_ countText: String) {
        noteCountLabel.title = countText
    }
    
}

extension ListView: UISearchFieldDelegate {
    
    func searchFieldEditingDidChange(_ searchText: String) {
        presenter.searchNotes(with: searchText)
    }
    
}

extension ListView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.noteCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as? UINoteCell else {
            return UITableViewCell()
        }
        if let note = presenter.note(at: indexPath.row) {
            cell.title = note.title
            cell.body = note.body
            cell.backgroundColor = .field
            cell.textColor = .text
        }
        return cell
    }
    
}

extension ListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.noteTapped(at: indexPath.row)
        searchField.cancelEditing()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            Task { [weak self] in
                await self?.presenter.deleteNote(at: indexPath.row)
                await MainActor.run {
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}
