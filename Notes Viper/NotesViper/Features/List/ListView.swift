//
//  ListViewController.swift
//  NotesViper
//
//  Created by James Wolfe on 20/01/2025.
//
import UIKit
import NotesStorage
import NotesUI

protocol ListViewProtocol: UIViewController {
    func reloadNotes()
    func updateNoteCount(_ countText: String)
    func present(error: Error)
    func clearSearchText()
    func toggleEditing()
    func removeNote(at index: Int)
}

final class ListViewController: UIViewController {
    
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
        UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(addNoteTapped))
    }()
    
    private lazy var editButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editNotesTapped))
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.loadNotes()
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
    @objc private func addNoteTapped() {
        presenter.addNoteTapped()
    }
    
    @objc private func editNotesTapped() {
        presenter.toggleEditing()
    }
    
}

extension ListViewController: ListViewProtocol {
    
    func reloadNotes() {
        tableView.reloadSections([0], with: .automatic)
    }
    
    func updateNoteCount(_ countText: String) {
        noteCountLabel.title = countText
    }
    
    func clearSearchText() {
        searchField.text = ""
    }
    
    func toggleEditing() {
        tableView.isEditing.toggle()
        editButton.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    func removeNote(at index: Int) {
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
}

extension ListViewController: UISearchFieldDelegate {
    
    func searchFieldEditingDidChange(_ searchText: String) {
        presenter.searchNotes(with: searchText)
    }
    
}

extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfNotes()
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

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectNote(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            self?.presenter.deleteNote(at: indexPath.row)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}
