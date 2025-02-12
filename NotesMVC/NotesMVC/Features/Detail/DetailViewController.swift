//
//  DetailViewController.swift
//  NotesMVC
//
//  Created by James Wolfe on 22/01/2025.
//

import UIKit
import NotesStorage
import NotesUI

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewController(dismissedNote note: NoteViewModel?, withText text: String)
}

final class DetailViewController: UIViewController {
    
    // MARK: - UI Elements
    lazy var editorField: UINoteEditor = {
        return UINoteEditor(frame: .zero,
                            textContainer: nil,
                            textColor: .text,
                            backgroundColor: .background)
    }()
    
    // MARK: - Data
    private let note: NoteViewModel?
    weak var delegate: DetailViewControllerDelegate?
    
    // MARK: - Initialization
    init(note: NoteViewModel?) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editorField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let text = editorField.text, !text.isEmpty else {
            return
        }
        
        delegate?.detailViewController(dismissedNote: note, withText: text)
    }
    
}

// MARK: - Setup
private extension DetailViewController {
    
    func setup() {
        view.backgroundColor = .background
        view.addSubview(editorField)
        
        let edgeInsets = UIEdgeInsets(
            top: .zero,
            left: 10,
            bottom: .zero,
            right: -10
        )
        editorField.constrainToSuperviewSafeArea(withEdgeInsets: edgeInsets)
        guard let note = note else { return }
        editorField.text = [note.title, note.body].joined(separator: "\n")
    }
    
}

#Preview {
    DetailViewController(note: nil)
}
