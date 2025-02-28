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
    
    let url: String
    let navTitle: String
    
    init(url: String, navTitle: String) {
        self.url = url
        self.navTitle = navTitle
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
