//
//  ViewConfig.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

protocol ViewConfig {
    func configHierarchy()
    func configLayout()
    func configView()
}

extension ViewConfig where Self: BaseViewController {
    func configBackgroundColor() {
        print(#function, "extension")
        view.backgroundColor = .systemBackground
    }
}
