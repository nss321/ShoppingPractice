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

    var isLiked: Bool = false {
        didSet {
        }
    }
    private let disposeBag = DisposeBag()
    
    private var viewModel: CustomLikeButtonViewModel!
    
    
    // TODO: 버튼이 상태를 따로 관리하는지?
    
    
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
        let input = CustomLikeButtonViewModel.Input(
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
    
    
    func config(frame: CGRect, action: UIAction) {
        self.frame = frame
        self.addAction(action, for: .touchUpInside)
    }
}
