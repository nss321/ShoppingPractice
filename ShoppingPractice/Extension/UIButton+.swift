//
//  UIButton+.swift
//  ShoppingPractice
//
//  Created by BAE on 2/7/25.
//

import UIKit

extension UIButton.Configuration {
    static func sortButtonStyle(title: String) -> UIButton.Configuration {
        var attribString = AttributedString(title)
        attribString.font = .systemFont(ofSize: 16)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = attribString
        config.baseForegroundColor = .label
        config.background.backgroundColor = .systemBackground
        config.background.strokeWidth = 1
        config.background.strokeColor = .white
        return config
    }
}
