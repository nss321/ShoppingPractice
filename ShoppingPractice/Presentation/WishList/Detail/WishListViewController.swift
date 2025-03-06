//
//  WishListViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class WishListViewController: BaseViewController {
    
    private let searchBar = {
        let view = UISearchBar()
        view.placeholder = "이곳에 추가하세요."
        view.barTintColor = .systemGroupedBackground
        view.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout())
        view.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "wishlist")
        return view
    }()
    
    var viewModel: WishListViewModel?
    
    override func bind() {
        let input = WishListViewModel.Input(
            searchButtonClicked: searchBar.rx.searchButtonClicked,
            searchBarText: searchBar.rx.text,
            itemSelect: collectionView.rx.itemSelected
        )
        let output = viewModel?.transform(input: input)
        
        output?.storedWishList
            .drive(collectionView.rx.items(cellIdentifier: "wishlist", cellType: UICollectionViewListCell.self)) ({ _, element, cell in
//                print("cell element", element)
                var content = cell.defaultContentConfiguration()
                content.text = element.title
                content.textProperties.color = .label
                content.textProperties.font = .systemFont(ofSize: 16)
//                content.secondaryText = element.content
//                content.secondaryTextProperties.font = .systemFont(ofSize: 12)
//                content.secondaryTextProperties.color = .secondaryLabel
                cell.contentConfiguration = content
                
                var backgroundConfig: UIBackgroundConfiguration
                backgroundConfig = UIBackgroundConfiguration.listCell()
                backgroundConfig.cornerRadius = 12
                cell.backgroundConfiguration = backgroundConfig
                
            })
            .disposed(by: disposeBag)
        
        output?.reload
            .drive(with: self) { owner, _ in
                print("reload observed")
//                owner.collectionView.section
//                owner.collectionView.reloadSections(<#T##sections: IndexSet##IndexSet#>)
//                owner.collectionView.deleteItems(at: [IndexPath(row: 0, section: 0)])
//                owner.collectionView.deleteSections(IndexSet(integer: 0))
//                owner.collectionView.rx.numb
                owner.collectionView.reloadData()
                
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(WishList.self)
            .bind(with: self) { owner, wishList in
                print(wishList)
                // TODO: 삭제 얼럿
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .bind(with: self) { owner, _ in
                owner.searchBar.text = ""
            }
            .disposed(by: disposeBag)
    }
    
    override func configLayout() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(smallMargin)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    override func configNavigation() {
        navigationItem.title = viewModel?.navTitle
    }
}

private extension WishListViewController {
    func layout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
}
