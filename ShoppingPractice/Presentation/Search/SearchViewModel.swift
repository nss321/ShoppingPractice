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
    
    // cache
    var items = Merchandise(total: 0, items: [MerchandiseInfo]())
    
    func transform(input: Input) -> Output {
        let shoppingKeyword = PublishRelay<String>()
        let isValid = PublishRelay<Bool>()
        
        input.searchButtonClick
        // 디바운스는 동작이 어색하다.
//            .debounce(.seconds(1), scheduler: MainScheduler.instance)
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
    
//    private func callRequest(text: String) {
//        print(#function, "서치바 엔터 후 호출")
//        ShoppingService.shared.callSearchReQuest(api: .basic(keyword: text), type: Merchandise.self) { [weak self] response in
//            self?.outputShoppingList.value = response
//            self?.items = response
//        }
//    }
    
    deinit {
        print(#function, "viewModel deinit")
    }
}
