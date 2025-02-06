//
//  SearchViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/6/25.
//

import UIKit

final class SearchViewModel {
    var lastSearched = ""
    let inputSearchText: Observable<String?> = Observable(nil)
    let outputShoppingList: Observable<Merchandise?> = Observable(nil)
    let outputAlert: Observable<UIAlertController?> = Observable(nil)
    
    // cache
    let items = Merchandise(total: 0, items: [MerchandiseInfo]())
    
    init() {
        inputSearchText.bind { [weak self] text in
            self?.checkValid(text: text)
        }
    }
    
    private func checkValid(text: String?) {
        guard let text else {
            print("failed to unwrapping searchbar text")
            return
        }
        
        if text == lastSearched {
            outputShoppingList.value = items
            return
        }
        
        if text.isEmpty {
            outputAlert.value = AlertManager.shared.showSimpleAlert(title: "공백", message: "공백은 검색할 수 없습니다.")
            return
        }
        
        if text.count < 2 {
            outputAlert.value = AlertManager.shared.showSimpleAlert(title: "검색어", message: "검색어는 2글자 이상 입력해주세요.")
            return
        } else {
            callRequest(text: text)
            lastSearched = text
        }
    }
    
    private func callRequest(text: String) {
        ShoppingService.shared.callSearchRequest(text: text) { [weak self] response in
            self?.outputShoppingList.value = response
        }
    }
    
    deinit {
        print(#function, "viewModel deinit")
    }
}
