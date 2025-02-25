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
    
    override func configLayout() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    override func configView() {
        searchBar.placeholder = "검색하세요."
        // TODO: 서치바 레이어에 대해 간단하게 기록해두면 좋을거 같다.
//        searchBar.backgroundColor = .blue
//        searchBar.searchTextField.backgroundColor = .red
        // UISearchBarBackround 계층
        searchBar.barTintColor = .systemGroupedBackground
        searchBar.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        searchBar.layer.borderWidth = 1
    }
    
    override func bind() {
        let input = SearchViewModel.Input(
            searchButtonClick: searchBar.rx.searchButtonClicked,
            searchKeyword: searchBar.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        output.shoppingKeyword
            .drive(with: self) { owner, keyword in
                print(self, keyword)
                let vc = ShoppingListViewController()
                vc.viewModel.searchKeyword.accept(keyword)
                owner.navigationController?.pushViewController(vc, animated: true)
            } onCompleted: { owner in
                print("onCompleted")
            } onDisposed: { owner in
                print("onDisposed")
            }
            .disposed(by: disposeBag)
    }
    
//    private func pushShoppingListViewController(items: Merchandise?, navTitle: String?) {
//        let vc = ShoppingListViewController()
//        
//        guard let items else {
//            AlertManager.shared.showSimpleAlert(title: "경고!", message: "failed to unwrapping items")
//            return
//        }
//        
//        vc.viewModel.lastSearched = viewModel.lastSearched
//        vc.viewModel.inputShoppingList.value = items
//        vc.navigationItem.titleView = UILabel().then {
//            $0.text = navTitle
//            $0.font = .systemFont(ofSize: 16, weight: .black)
//        }
//        navigationController?.pushViewController(vc, animated: true)
//    }
}
