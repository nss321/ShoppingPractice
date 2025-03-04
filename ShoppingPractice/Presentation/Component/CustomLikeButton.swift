//
//  CustomLikeButton.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class CustomLikeButton: BaseButton {

    var viewModel: CustomLikeButtonViewModel!
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configButton()
    }
    
    private func configButton() {
        let image = UIImage(systemName: "heart")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        configuration = .plain()
        configuration?.image = image
        configuration?.background.backgroundColor = .secondarySystemBackground
        configuration?.cornerStyle = .capsule
    }
    
    func bind(viewModel: CustomLikeButtonViewModel) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        let buttonConfig = Observable.just(())
        
        let input = CustomLikeButtonViewModel.Input(
            buttonConfig: buttonConfig,
            likeButtonTap: rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.isLiked
            .drive(with: self) { owner, isLiked in
                if isLiked {
                    owner.configuration?.image = UIImage(systemName: "heart.fill")?.withTintColor(.label, renderingMode: .alwaysOriginal)
                } else {
                    owner.configuration?.image = UIImage(systemName: "heart")?.withTintColor(.label, renderingMode: .alwaysOriginal)
                }
            }
            .disposed(by: disposeBag)
        
    }
}
