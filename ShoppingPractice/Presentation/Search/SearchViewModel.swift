//
//  SearchViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/6/25.
//

import RxSwift
import RxCocoa

final class SearchViewModel: ViewModel {
    var lastSearched = ""

    struct Input {
        let searchButtonClick: ControlEvent<Void>
        let searchKeyword: ControlProperty<String>
    }
    struct Output {
        let alertMessage: Driver<String>
        let shoppingList: Driver<Merchandise>
    }

    private let disposeBag = DisposeBag()
    let inputSearchText: CustomObservable<String?> = CustomObservable(nil)
    let outputShoppingList: CustomObservable<Merchandise?> = CustomObservable(nil)
//    let outputAlert: Observable<UIAlertController?> = Observable(nil)
    
    // cache
    var items = Merchandise(total: 0, items: [MerchandiseInfo]())
    
    init() {
//        inputSearchText.lazyBind { [weak self] text in
//            self?.checkValid(text: text)
//        }
    }
    
    func transform(input: Input) -> Output {
        let alertMessage = PublishRelay<String>()
        let shoppingList = PublishRelay<Merchandise>()
        let isValidRelay = PublishRelay<Bool>()
        
        /*
         1. 버튼 클릭하면 유효성 검증 -> 얼럿 메시지로 바인딩
         2.
         */
        input.searchButtonClick
            .withLatestFrom(input.searchKeyword)
            .map({ keyword -> Bool in
                return keyword.count < 2 ? true : false
            })
            .bind(with: self) { owner, isValid in
                if isValid {
                    alertMessage.accept("검색어는 2글자 이상 입력해주세요.")
                } else {
                    isValidRelay.accept(isValid)
                }
            }
            .disposed(by: disposeBag)
        
        isValidRelay
            .withLatestFrom(input.searchKeyword)
            .bind(with: self) { owner, keyword in
                print(keyword)
            }
            .disposed(by: disposeBag)
        
        
        return Output(alertMessage: alertMessage.asDriver(onErrorJustReturn: "-"),
                      shoppingList: shoppingList.asDriver(onErrorJustReturn: Merchandise(total: 0, items: []))
        )
    }
    
//    private func checkValid(text: String?) {
//        guard let text else {
//            print("failed to unwrapping searchbar text")
//            return
//        }
//        
//        if text == lastSearched {
//            outputShoppingList.value = items
//            return
//        }
//        
//        if text.isEmpty {
//            outputAlert.value = AlertManager.shared.showSimpleAlert(title: "공백", message: "공백은 검색할 수 없습니다.")
//            return
//        }
//        
//        if text.count < 2 {
//            outputAlert.value = AlertManager.shared.showSimpleAlert(title: "검색어", message: "검색어는 2글자 이상 입력해주세요.")
//            return
//        } else {
//            callRequest(text: text)
//            lastSearched = text
//        }
//    }
    
    private func callRequest(text: String) {
        print(#function, "서치바 엔터 후 호출")
        ShoppingService.shared.callSearchReQuest(api: .basic(keyword: text), type: Merchandise.self) { [weak self] response in
            self?.outputShoppingList.value = response
            self?.items = response
        }
    }
    
    deinit {
        print(#function, "viewModel deinit")
    }
}
