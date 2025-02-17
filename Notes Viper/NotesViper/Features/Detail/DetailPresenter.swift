//
//  DetailPresenter.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//

import UIKit
import NotesStorage

protocol DetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewWillDisappear(withText text: String?)
}

protocol DetailInteractorOutputProtocol: AnyObject {
    func didFetchNoteContent(title: String, body: String)
}

final class DetailPresenter: DetailPresenterProtocol, DetailInteractorOutputProtocol {
    
    weak var view: DetailViewProtocol?
    var interactor: DetailInteractorProtocol
    var router: DetailRouterProtocol
    
    init(view: DetailViewProtocol, interactor: DetailInteractorProtocol, router: DetailRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewDidLoad() {
        interactor.fetchNoteContent()
    }
    
    func viewWillDisappear(withText text: String?) {
        interactor.saveNoteContent(text)
    }
    
    func didFetchNoteContent(title: String, body: String) {
        view?.displayNoteContent(title: title, body: body)
    }
    
}
