//
//  CustomLikeButton.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit
import SnapKit
import Then

final class CustomLikeButton: BaseButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configButton()
    }
    
    private func configButton() {
        clipsToBounds = true
        
        var config = UIButton.Configuration.plain()
        let image = UIImage(systemName: "heart")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        config.image = image
        config.background.backgroundColor = .white
        
        self.configuration = config
    }
    
    func config(frame: CGRect, action: UIAction) {
        self.frame = frame
        self.addAction(action, for: .touchUpInside)
    }
    
}
