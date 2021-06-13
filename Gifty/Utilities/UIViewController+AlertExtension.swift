//
//  UIViewController+AlertExtension.swift
//  Gifty
//
//  Created by Matt Bryant on 6/12/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Show an alert with title, message, and actions
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert message
    ///   - style: The alert style, ie alert or action sheet
    ///   - actions: The UIAlertActions
    func showAlert(with title: String, message: String, style: UIAlertController.Style, actions: [UIAlertAction]?) {
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        if let actions = actions {
            actions.forEach({
                alert.addAction($0)
            })
        }
        
        present(alert, animated: true, completion: nil)
    }
}
