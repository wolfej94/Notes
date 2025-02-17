//
//  DetailRouter.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//

import UIKit
import NotesStorage

protocol DetailRouterProtocol: AnyObject {
    static func createModule(with note: NoteViewModel?, storageProvider: DetailStorageProvider?) -> UIViewController
}

final class DetailRouter: DetailRouterProtocol {
    
    static func createModule(with note: NoteViewModel?, storageProvider: DetailStorageProvider?) -> UIViewController {
        let view = DetailViewController()
        let interactor = DetailInteractor(note: note, storageProvider: storageProvider)
        let router = DetailRouter()
        let presenter = DetailPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        return view
    }
    
}
