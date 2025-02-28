//
//  DetailView.swift
//  NotesViper
//
//  Created by James Wolfe on 22/01/2025.
//

import UIKit
import NotesStorage
import NotesUI

protocol DetailViewProtocol: AnyObject {
    @MainActor func displayNoteContent(title: String, body: String)
    @MainActor func present(error: Error)
}

final class DetailView: UIViewController {
    
    // MARK: - UI Elements
    lazy var editorField: UINoteEditor = {
        return UINoteEditor(frame: .zero,
                            textContainer: nil,
                            textColor: .text,
                            backgroundColor: .background)
    }()
    
    // MARK: - Properties
    var presenter: DetailPresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editorField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear(withText: editorField.text)
    }
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .background
        view.addSubview(editorField)
        let edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        editorField.constrainToSuperviewSafeArea(withEdgeInsets: edgeInsets)
    }
    
}

extension DetailView: DetailViewProtocol {
    
    func displayNoteContent(title: String, body: String) {
        editorField.text = [title, body]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }
    
}
