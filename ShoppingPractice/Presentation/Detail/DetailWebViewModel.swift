//
//  DetailWebViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/27/25.
//

import RxSwift
import RxCocoa

final class DetailWebViewModel: ViewModel {
    struct Input {
        let likeButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        
    }
    
    let item: MerchandiseInfo
    var completion: (() -> Void)?
    
    init(item: MerchandiseInfo) {
        self.item = item
    }
    
    deinit {
        completion?()
        print("viewmodel deinit")
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
