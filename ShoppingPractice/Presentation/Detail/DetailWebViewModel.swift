//
//  DetailWebViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/27/25.
//

import Foundation

import RxSwift
import RxCocoa

final class DetailWebViewModel: ViewModel {
    struct Input { }
    
    struct Output { }
    
    let item: MerchandiseInfo
    var completion: (() -> Void)?
    var request: URLRequest {
        URLRequest(url: URL(string: item.link)!)
    }
    
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
