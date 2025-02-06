//
//  ViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//  4h30m

import UIKit

import SnapKit
import Then

class SearchViewController: BaseViewController {
    
    let searchBar = UISearchBar()
    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func configHierarchy() {
        view.addSubview(searchBar)
    }
    
    override func configLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    override func configView() {
        searchBar.delegate = self
        searchBar.placeholder = "검색하세요."
    }
    
    func bind() {
        viewModel.outputShoppingList.lazyBind { [weak self] response in
            self?.pushShoppingListViewController(items: response, navTitle: self?.searchBar.text)
        }
        viewModel.outputAlert.lazyBind { [weak self] alert in
            self?.present(alert!, animated: true)
        }
    }
    
    func pushShoppingListViewController(items: Merchandise?, navTitle: String?) {
        print(#function)
        let vc = ShoppingListViewController()
        
        guard let items else {
            let alert = AlertManager.shared.showSimpleAlert(title: "경고!", message: "failed to unwrapping items")
            present(alert, animated: true)
            return
        }
        
        vc.shoppingItemsAndTotal = items
        vc.lastSearched = viewModel.lastSearched
        vc.navigationItem.titleView = UILabel().then {
            $0.text = navTitle
            $0.font = .systemFont(ofSize: 16, weight: .black)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function,"입력된 문자열(\(searchBar.text!)")
        view.endEditing(true)
        
        viewModel.inputSearchText.value = searchBar.text
    }
}
