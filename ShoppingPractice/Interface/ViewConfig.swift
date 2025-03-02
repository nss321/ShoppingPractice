//
//  ViewConfig.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

protocol ViewConfig {
    func configLayout()
    func configView()
}

extension ViewConfig where Self: BaseViewController {
    func configBackgroundColor() {
        view.backgroundColor = .systemGroupedBackground
    }
}
