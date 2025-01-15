//
//  UIViewController+.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, handler: ((UIAlertAction)->Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: handler)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
