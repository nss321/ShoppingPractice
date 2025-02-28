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
    }
    private let disposeBag = DisposeBag()
    
    let id: String
    
    init(id: String) {
        self.id = id
        print(id)
    }
    
    
    func transform(input: Input) -> Output {
        
        input.likeButtonTap
            .bind(with: self) { owner, _ in
                print(owner.id, "선택")
                var origin = Set(UserDefaultsManager.shared.like)
                print("기존 값 >> ", origin)
                if origin.contains(owner.id) {
                    origin.remove(owner.id)
                    print("삭제 >>> ")
                } else {
                    origin.insert(owner.id)
                    print("추가 >>> ")
                }
                UserDefaultsManager.shared.like = Array(origin)
                print("저장된 값", UserDefaultsManager.shared.like)
            }
            .disposed(by: disposeBag)
        
        return Output(
        )
    }
}
