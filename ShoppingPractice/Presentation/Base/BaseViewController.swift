//
//  BaseViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/17/25.
//

import UIKit

import RxSwift
import SnapKit
import Then


class BaseViewController: UIViewController, ViewConfig {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configHierarchy()
        configLayout()
        configView()
        configNavigation()
        configBackgroundColor()
    }
    
    func bind() { }
    
    func configHierarchy() { }
    
    func configLayout() { }
    
    func configView() { }
    
    func configNavigation() { }
    
}
