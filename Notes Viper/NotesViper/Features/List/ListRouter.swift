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
    
    weak var viewController: ListViewController?
    
    static func createModule() -> UIViewController {
        let view = ListViewController()
        let storage = NotesStorage()
        let interactor = ListInteractor(storage: storage)
        let router = ListRouter()
        let presenter = ListPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToDetail(note: NoteViewModel?) {
        let detailVC = DetailRouter.createModule(with: note, storageProvider: viewController)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
