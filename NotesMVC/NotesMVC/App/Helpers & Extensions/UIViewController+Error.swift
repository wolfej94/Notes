//
//  UIViewController+Error.swift
//  NotesMVC
//
//  Created by James Wolfe on 24/01/2025.
//

import UIKit

extension UIViewController {
    
    func present(error: Error) {
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
    
}
