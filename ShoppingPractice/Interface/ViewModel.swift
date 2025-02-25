//
//  ViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/25/25.
//

import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
