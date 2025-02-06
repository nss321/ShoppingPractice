//
//  Observable.swift
//  ShoppingPractice
//
//  Created by BAE on 2/6/25.
//

final class Observable<T> {
    var value: T {
        didSet {
            closure?(value)
        }
    }
    
    private var closure: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(closure: @escaping (T)->Void) {
        closure(value)
        self.closure = closure
    }
    
    func lazyBind(closure: @escaping (T)->Void) {
        self.closure = closure
    }
}
