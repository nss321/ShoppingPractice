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
    private var currentFilter = BehaviorRelay<SortBy>(value: .sim)
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let simFilter: ControlEvent<Void>
        let dateFilter: ControlEvent<Void>
        let dscFilter: ControlEvent<Void>
        let ascFilter: ControlEvent<Void>
        let prefetchIndex: ControlEvent<[IndexPath]>
        let itemSelect: ControlEvent<MerchandiseInfo>
    }
    
    struct Output {
        let navTitle: Driver<String>
        let searchResult: Driver<[MerchandiseInfo]>
        let totalNumber: Driver<String?>
        let errorNoti: Driver<String>
//        let vc: Driver<ShoppingListViewController>
    }
    
    func transform(input: Input) -> Output {
        var result = BehaviorRelay<[MerchandiseInfo]>(value: [])
        let totalNumber = PublishRelay<String?>()
        let errroNoti = PublishRelay<String>()
        let shoppingListVC = PublishRelay<DetailWebViewController>()
        
        
        // MARK: operator 부분과 bind 부분이 똑같은데 이것도 줄일 수는 없는지?
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
                    errroNoti.accept(error.rawValue)
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
                    .bind(with: self) { owner, response in
                        switch response {
                        case .success(let value):
                            result.accept(value.items)
                            totalNumber.accept(owner.configTotalCount(total: value.total))
                            owner.currentFilter.accept(sort)
                        case .failure(let error):
                            dump(error)
                            errroNoti.accept(error.rawValue)
                        }
                    }
                    .disposed(by: disposeBag)
            }
        
        // TODO: 프리패칭 시점 로직 추가
        PublishRelay
            .combineLatest(input.prefetchIndex, currentFilter, searchKeyword, result)
            .map { (index, sortBy, keyword, result) in
                return (index.last?.item ?? 0, sortBy, keyword, result.count)
            }
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { (item, sortBy, keyword, current) -> Single<Result<Merchandise, APIError>> in
                print("현재 페이지 수", current, "인덱스",item)
                if current - 10 < item {
                    return ShoppingService.shared.callSearchAPI(api: .sorted(keyword: keyword, sortby: sortBy, startAt: current), type: Merchandise.self)
                } else {
                    return Single.create { value in
                        value(.success(.success(Merchandise.empty())))
                        return Disposables.create()
                    }
                }
            }
            .bind(with: self) { owner, response in
                switch response {
                case .success(let value):
                    if value.total == 0 { return }
                    else {
                        let newValue = result.value + value.items
                        result.accept(newValue)
                    }
                case .failure(let error):
                    dump(error)
                    errroNoti.accept(error.rawValue)
                }
            }
            .disposed(by: disposeBag)
        
//        input.itemSelect
//            .bind { item in
//                shoppingListVC.accept(.)
//            }
        
        return Output(navTitle: searchKeyword.asDriver(),
                      searchResult: result.asDriver(onErrorDriveWith: .empty()),
                      totalNumber: totalNumber.asDriver(onErrorDriveWith: .empty()),
                      errorNoti: errroNoti.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    // MARK: - given properties
//    var lastSearched = ""
//    var lastFilter: SortBy = .sim
    
    // MARK: - properties
    let spacing: CGFloat = 12
//    var currentPage: Int {
//        return outputShoppingList.value.count
//    }
//    
//    // MARK: - observed properties
//    let inputSearchText: CustomObservable<String?> = CustomObservable(nil)
//    let inputShoppingList: CustomObservable<Merchandise?> = CustomObservable(nil)
//    let inputPrefetching: CustomObservable<Void?> = CustomObservable(())
//    let inputSortButtonTapped: CustomObservable<SortBy?> = CustomObservable(nil)
//    
//    let outputShoppingList: CustomObservable<[MerchandiseInfo]> = CustomObservable([])
//    let outputTotalCount = CustomObservable("")
//    var outputIsSorted = CustomObservable(false)
    
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
    
//    private func callSortedRequest() {
////        print(#function, "프리패칭 리퀘스트 콜!!")
//        ShoppingService.shared.callSearchReQuest(api: .sorted(keyword: lastSearched, sortby: lastFilter, startAt: currentPage), type: Merchandise.self) { [weak self] response in
//            self?.outputShoppingList.value.append(contentsOf: response.items)
//        }
//        
//    }
}
