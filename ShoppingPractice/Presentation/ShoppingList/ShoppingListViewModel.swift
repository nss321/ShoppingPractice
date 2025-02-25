//
//  ShoppingListViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/6/25.
//

import Foundation

import RxSwift
import RxCocoa

final class ShoppingListViewModel: ViewModel {
    
    let searchKeyword = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let simFilter: ControlEvent<Void>
        let dateFilter: ControlEvent<Void>
        let dscFilter: ControlEvent<Void>
        let ascFilter: ControlEvent<Void>
    }
    
    struct Output {
        let navTitle: Driver<String>
        let searchResult: Driver<[MerchandiseInfo]>
        let totalNumber: Driver<String?>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishRelay<[MerchandiseInfo]>()
        let totalNumber = PublishRelay<String?>()
        
        searchKeyword
            .flatMap { keyword in
                ShoppingService.shared.callSearchAPI(api: .sorted(keyword: keyword, sortby: .sim, startAt: 1), type: Merchandise.self)
            }
            .bind(with: self) { owner, value in
                switch value {
                case .success(let response):
                    result.accept(response.items)
                    totalNumber.accept(owner.configTotalCount(total: response.total))
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        [
            (input.simFilter, SortBy.sim),
            (input.dateFilter, SortBy.date),
            (input.dscFilter, SortBy.dsc),
            (input.ascFilter, SortBy.asc)
        ]
            .forEach { tap, sort in
                tap
                    .withLatestFrom(searchKeyword)
                    .flatMap {
                        ShoppingService.shared.callSearchAPI(api: .sorted(keyword: $0, sortby: sort, startAt: 1), type: Merchandise.self)
                    }
                    .bind(with: self) { owner, value in
                        switch value {
                        case .success(let response):
                            result.accept(response.items)
                            totalNumber.accept(owner.configTotalCount(total: response.total))
                        case .failure(let error):
                            print(error)
                        }
                    }
                    .disposed(by: disposeBag)
            }
        
        return Output(navTitle: searchKeyword.asDriver(),
                      searchResult: result.asDriver(onErrorDriveWith: .empty()),
                      totalNumber: totalNumber.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    // MARK: - given properties
    var lastSearched = ""
    var lastFilter: SortBy = .sim
    
    // MARK: - properties
    let spacing: CGFloat = 12
    var currentPage: Int {
        return outputShoppingList.value.count
    }
    
    // MARK: - observed properties
    let inputSearchText: CustomObservable<String?> = CustomObservable(nil)
    let inputShoppingList: CustomObservable<Merchandise?> = CustomObservable(nil)
    let inputPrefetching: CustomObservable<Void?> = CustomObservable(())
    let inputSortButtonTapped: CustomObservable<SortBy?> = CustomObservable(nil)
    
    let outputShoppingList: CustomObservable<[MerchandiseInfo]> = CustomObservable([])
    let outputTotalCount = CustomObservable("")
    var outputIsSorted = CustomObservable(false)
    
//    init() {
//        inputShoppingList.bind { [weak self] response in
//            if let response = response, let total = self?.configTotalCount(total: response.total) {
//                self?.outputShoppingList.value = response.items
//                self?.outputTotalCount.value = total
//            }
//        }
//        inputPrefetching.lazyBind { [weak self] _ in
//            self?.callSortedRequest()
//        }
//        inputSortButtonTapped.lazyBind { [weak self] sortby in
//            self?.outputIsSorted.value.toggle()
//            if self?.lastFilter == sortby {
//                return
//            } else {
//                if let lastSearched = self?.lastSearched, let sortby = sortby {
//                    ShoppingService.shared.callSearchReQuest(api: .sorted(keyword: lastSearched, sortby: sortby), type: Merchandise.self) { response in
//                        self?.outputShoppingList.value = response.items
//                        self?.lastFilter = sortby
//                    }
//                }
//            }
//        }
//    }
    
    private func configTotalCount(total: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for: total)
    }
    
    private func callSortedRequest() {
//        print(#function, "프리패칭 리퀘스트 콜!!")
        ShoppingService.shared.callSearchReQuest(api: .sorted(keyword: lastSearched, sortby: lastFilter, startAt: currentPage), type: Merchandise.self) { [weak self] response in
            self?.outputShoppingList.value.append(contentsOf: response.items)
        }
        
    }
}
