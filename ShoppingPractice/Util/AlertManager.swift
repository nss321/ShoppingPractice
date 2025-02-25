//
//  AlertManager.swift
//  ShoppingPractice
//
//  Created by BAE on 2/6/25.
//

import UIKit

final class AlertManager {
    static let shared = AlertManager()
    
    private init() { }
    
    private func root() -> UIViewController {
        UIApplication.shared.keyWindow!.rootViewController!
    }
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        root().present(alert, animated: true)
    }
}
