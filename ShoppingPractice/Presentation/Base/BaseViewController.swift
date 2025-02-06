//
//  BaseViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/17/25.
//

import UIKit
import SnapKit
import Then

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func configureHierarchy() { }
    
    func configureLayout() { }
    
    func configureView() { }
    
    func configNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left")!.withTintColor(.white, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(popThisViewController))
    }
    
    func makeButtonConfig(title: String) -> UIButton.Configuration {
        var attribString = AttributedString(title)
        attribString.font = .systemFont(ofSize: 16)
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = attribString
        
        // plain 버튼의 글자색은 baseForegroundColor로 변경
        config.baseForegroundColor = .white
        config.background.backgroundColor = .black
        config.background.strokeWidth = 1
        config.background.strokeColor = .white
        
        return config
    }

    @objc
    func popThisViewController(_ sender: UIBarButtonItem) {
        print(#function)
        navigationController?.popViewController(animated: true)
    }
}
