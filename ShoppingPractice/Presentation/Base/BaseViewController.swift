//
//  BaseViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/17/25.
//

import UIKit
import SnapKit
import Then

class BaseViewController: UIViewController, ViewConfig {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configHierarchy()
        configLayout()
        configView()
        configNavigation()
        configBackgroundColor()
    }
    
    func configHierarchy() { }
    
    func configLayout() { }
    
    func configView() { }
    
    func configNavigation() { }
}
