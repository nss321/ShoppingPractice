//
//  ShoppingListViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/6/25.
//

import Foundation

final class ShoppingListViewModel {
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
    
    init() {
        inputShoppingList.bind { [weak self] response in
            if let response = response, let total = self?.configTotalCount(total: response.total) {
                self?.outputShoppingList.value = response.items
                self?.outputTotalCount.value = total
            }
        }
        inputPrefetching.lazyBind { [weak self] _ in
            self?.callSortedRequest()
        }
        inputSortButtonTapped.lazyBind { [weak self] sortby in
            self?.outputIsSorted.value.toggle()
            if self?.lastFilter == sortby {
                return
            } else {
                if let lastSearched = self?.lastSearched, let sortby = sortby {
                    ShoppingService.shared.callSearchReQuest(api: .sorted(keyword: lastSearched, sortby: sortby), type: Merchandise.self) { response in
                        self?.outputShoppingList.value = response.items
                        self?.lastFilter = sortby
                    }
                }
            }
        }
    }
    
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
