//
//  ViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//  4h30m

import UIKit
import Then

class ViewController: BaseViewController {
    
    override var shoppingItemsAndTotal: Merchandise {
        didSet {
            print("didset")
            self.pushShoppingListViewController(items: self.shoppingItemsAndTotal, navTitle: searchBar.searchTextField.text!)
        }
    }
        
    override func configureView() {
        searchBar.delegate = self
        searchBar.placeholder = "검색하세요."
    }
    
    func callRequest(text: String) {
        ShoppingService.shared.callSearchRequest(text: text) {
            if $0.items.isEmpty {
                self.showAlert(title: "검색 결과", message: "검색 결과가 없습니다.", handler: nil)
            } else {
                self.shoppingItemsAndTotal = $0

            }
        }
    }
    
    func pushShoppingListViewController(items: Merchandise, navTitle: String) {
        print(#function)
        let vc = ShoppingListViewController()
        vc.shoppingItemsAndTotal = items
        vc.lastSearched = lastSearched
        vc.navigationItem.titleView = UILabel().then {
            $0.text = navTitle
            $0.font = .systemFont(ofSize: 16, weight: .black)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function,"입력된 문자열(\(searchBar.text!)")
        view.endEditing(true)
        
        guard let text = searchBar.text else {
            print("failed to unwrapping searchbar text")
            return
        }
        
        if text == lastSearched {
            pushShoppingListViewController(items: shoppingItemsAndTotal, navTitle: text)
        } else {
            let trimmedText = text.filter({!$0.isWhitespace})
            if  trimmedText.isEmpty  {
                showAlert(title: "공백", message: "공백은 검색할 수 없습니다.", handler: nil)
            } else if trimmedText.count < 2 {
                showAlert(title: "검색어", message: "검색어는 2글자 이상 입력해주세요.", handler: nil)
            } else {
                callRequest(text: text)
                lastSearched = text
            }
        }

    }
}
