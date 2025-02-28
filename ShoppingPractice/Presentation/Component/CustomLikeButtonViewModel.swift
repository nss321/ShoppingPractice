//
//  CustomLikeButtonViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/28/25.
//

import RxSwift
import RxCocoa

final class CustomLikeButtonViewModel: ViewModel {
    struct Input {
        let likeButtonTap: ControlEvent<Void>
    }
    struct Output {
        let isLiked: Driver<Bool>
    }
    private let disposeBag = DisposeBag()
    
    private let id: String
    
    init(id: String) {
        self.id = id
        print(id)
        print(#function, "viewmodel init id =", id)
    }
    
    
    func transform(input: Input) -> Output {
        let isLiked = BehaviorRelay(value: false)
        
        input.likeButtonTap
            .bind(with: self) { owner, _ in
                print("viewmodel input tap")
                isLiked.accept(owner.saveLike())
            }
            .disposed(by: disposeBag)
        
        return Output(
            isLiked: isLiked.asDriver()
        )
    }
    
    private func saveLike() -> Bool {
        var isLiked: Bool
        var origin = Set(UserDefaultsManager.shared.like)
        if origin.contains(id) {
            origin.remove(id)
            isLiked = false
        } else {
            origin.insert(id)
            isLiked = true
        }
        UserDefaultsManager.shared.like = Array(origin)
        return isLiked
    }
}
