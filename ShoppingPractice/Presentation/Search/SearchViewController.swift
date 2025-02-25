//
//  ViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//  4h30m

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then
/*
 1. 서치바 입력, 텍스트 전달
 2. 유효성 검증
 3. 적절하지 않다면?
    3-1. 얼럿 표시
 4. 적절하다면?
    4-1. 네트워크 요청
 5. 화면전환
 
 
 
 */
final class SearchViewController: BaseViewController {
    
    private let searchBar = UISearchBar()
    private let viewModel = SearchViewModel()
    
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
//        searchBar.delegate = self
        searchBar.placeholder = "검색하세요."
    }
    
    override func bind() {
        let input = SearchViewModel.Input(
            searchButtonClick: searchBar.rx.searchButtonClicked,
            searchKeyword: searchBar.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        output.alertMessage
            .drive(with: self) { owner, value in
                AlertManager.shared.showSimpleAlert(title: "검색어", message: value)
            } onCompleted: { owner in
                print("onCompleted")
            } onDisposed: { owner in
                print("onDisposed")
            }
            .disposed(by: disposeBag)

        
//        viewModel.outputShoppingList.lazyBind { [weak self] response in
//            self?.pushShoppingListViewController(items: response, navTitle: self?.searchBar.text)
//        }
//        viewModel.outputAlert.lazyBind { [weak self] alert in
//            self?.present(alert!, animated: true)
//        }
    }
    
    private func pushShoppingListViewController(items: Merchandise?, navTitle: String?) {
        let vc = ShoppingListViewController()
        
        guard let items else {
            AlertManager.shared.showSimpleAlert(title: "경고!", message: "failed to unwrapping items")
            return
        }
        
        vc.viewModel.lastSearched = viewModel.lastSearched
        vc.viewModel.inputShoppingList.value = items
        vc.navigationItem.titleView = UILabel().then {
            $0.text = navTitle
            $0.font = .systemFont(ofSize: 16, weight: .black)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
//
//extension SearchViewController: UISearchBarDelegate {
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print(#function,"입력된 문자열(\(searchBar.text!)")
//        view.endEditing(true)
//        viewModel.inputSearchText.value = searchBar.text
//    }
//}
