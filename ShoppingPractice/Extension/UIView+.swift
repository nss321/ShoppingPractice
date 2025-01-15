//
//  UIView+.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}
