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
        let buttonConfig: Observable<Void>
        let likeButtonTap: ControlEvent<Void>
    }
    struct Output {
        let isLiked: Driver<Bool>
    }
    private let disposeBag = DisposeBag()
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    func transform(input: Input) -> Output {
        let isLiked = BehaviorRelay(value: false)
        
        input.buttonConfig
            .bind(with: self) { owner, _ in
                isLiked.accept(owner.loadLike())
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .bind(with: self) { owner, _ in
                isLiked.accept(owner.toggleLike())
            }
            .disposed(by: disposeBag)
        
        return Output(
            isLiked: isLiked.asDriver()
        )
    }
    
    private func toggleLike() -> Bool {
//        var isLiked: Bool
//        var origin = Set(UserDefaultsManager.shared.like)
//        if origin.contains(id) {
//            origin.remove(id)
//            isLiked = false
//        } else {
//            origin.insert(id)
//            isLiked = true
//        }
//        UserDefaultsManager.shared.like = Array(origin)
//        return isLiked
        var isLiked: Bool
        var origin = UserDefaultsManager.likeList
        if origin.contains(id) {
            origin.remove(id)
            isLiked = false
        } else {
            origin.insert(id)
            isLiked = true
        }
        UserDefaultsManager.likeList = origin
        return isLiked
    }
    
    private func loadLike() -> Bool {
//        return Set(UserDefaultsManager.shared.like).contains(id)
        return UserDefaultsManager.likeList.contains(id)
    }
    
}
