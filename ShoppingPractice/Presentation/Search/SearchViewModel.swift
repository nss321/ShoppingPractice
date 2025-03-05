//
//  SearchViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/6/25.
//

import RxSwift
import RxCocoa

final class SearchViewModel: ViewModel {
    
    private enum KeywordValidation: String {
        case short
        
        var message: String {
            switch self {
            case .short:
                return "검색어는 2글자 이상 입력해주세요."
            }
        }
    }

    struct Input {
        let searchButtonClick: ControlEvent<Void>
        let searchKeyword: ControlProperty<String>
    }
    struct Output {
        let shoppingKeyword: Driver<String>
    }

    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let shoppingKeyword = PublishRelay<String>()
        let isValid = PublishRelay<Bool>()
        
        input.searchButtonClick
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchKeyword)
            .map({ keyword -> Bool in
                return keyword.count < 2 ? true : false
            })
            .bind(with: self) { owner, value in
                if value {
                    AlertManager.shared.showSimpleAlert(title: "검색어", message: KeywordValidation.short.message)
                } else {
                    isValid.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        isValid
            .withLatestFrom(input.searchKeyword)
            .bind(to: shoppingKeyword)
            .disposed(by: disposeBag)
        
        return Output(shoppingKeyword: shoppingKeyword.asDriver(onErrorDriveWith: .empty()))
    }
    
    deinit {
        print(#function, "viewModel deinit")
    }
}
