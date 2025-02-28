//
//  ListRouter.swift
//  NotesViper
//
//  Created by James Wolfe on 17/02/2025.
//

import UIKit
import NotesStorage

protocol ListRouterProtocol: AnyObject {
    func navigateToDetail(note: NoteViewModel?)
}

final class ListRouter: ListRouterProtocol {
    
    weak var view: ListView?
    
    static func createModule() -> UIViewController {
        let view = ListView()
        let interactor = ListInteractor()
        let router = ListRouter()
        let presenter = ListPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.view = view
        
        return view
    }
    
    func navigateToDetail(note: NoteViewModel?) {
        let detailVC = DetailRouter.createModule(with: note)
        view?.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
