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
    
//    var viewModel: CustomLikeButtonViewModel!
    
    
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
        
//        configurationUpdateHandler = { [weak self] btn in
//            switch btn.state {
//            case .highlighted:
//                print("button highlighted")
//                self?.configuration?.background.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.1)
//            case .selected:
//                print("button selected")
//            default:
//                print("button state is default")
//                self?.configuration?.background.backgroundColor = .secondarySystemBackground
//            }
//        }
    }
    
    func bind(viewModel: CustomLikeButtonViewModel) {
        let input = CustomLikeButtonViewModel.Input(
            likeButtonTap: self.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        rx.tap
            .bind(with: self) { owner, _ in
                print("\(viewModel.id) Button Tapped")
            }
            .disposed(by: disposeBag)
        
    }
    
    
    func config(frame: CGRect, action: UIAction) {
        self.frame = frame
        self.addAction(action, for: .touchUpInside)
    }
}
