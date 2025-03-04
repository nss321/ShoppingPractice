//
//  ViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//  4h30m

import UIKit

import RealmSwift
import RxSwift
import RxCocoa
import SnapKit

final class SearchViewController: BaseViewController {
    
    private let searchBar = UISearchBar()
    private let viewModel = SearchViewModel()
    
    let realm = try! Realm()
    
    override func configLayout() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
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
        
//        let origin = UserDefaultsManager.likeList
//        let newValue = origin.map {
//            MerchandiseInfo(
//                id: $0,
//                title: <#T##String#>,
//                image: <#T##String#>,
//                price: <#T##String#>,
//                mall: <#T##String#>,
//                link: <#T##String#>)
//        }
        
        print(realm.configuration.fileURL)
    }
    
    override func configNavigation() {
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .label
        let wishButton = UIBarButtonItem(
            image: UIImage(systemName: "list.number"),
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.navigationController?.pushViewController(WishListViewController(), animated: true)
            }))
        let likeButton = UIBarButtonItem(
            image: UIImage(systemName: "heart.fill"),
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.navigationController?.pushViewController(LikeListViewController(), animated: true)
            }))
        navigationItem.rightBarButtonItems = [likeButton, wishButton]
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
            }
            .disposed(by: disposeBag)
    }
}
