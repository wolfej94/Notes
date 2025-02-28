//
//  DetailRouter.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//

import UIKit
import NotesStorage

protocol DetailRouterProtocol: AnyObject {
    static func createModule(with note: NoteViewModel?) -> UIViewController
}

final class DetailRouter: DetailRouterProtocol {
    
    static func createModule(with note: NoteViewModel?) -> UIViewController {
        let view = DetailView()
        let interactor = DetailInteractor(note: note)
        let router = DetailRouter()
        let presenter = DetailPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
    
}
