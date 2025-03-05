//
//  WishListViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import UIKit

import RealmSwift
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
            searchBarText: searchBar.rx.text)
        let output = viewModel?.transform(input: input)
        
        output?.storedWishList
            .drive(collectionView.rx.items(cellIdentifier: "wishlist", cellType: UICollectionViewListCell.self)) ({ _, element, cell in
                
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
//        configuration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
    
//    func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
//        guard let indexPath = indexPath,
//                let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
//        
//        // 왜 3번, 1번 총 4번 호출되는걸까
//        print(item)
//        
//        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
//            if let index = self?.filledList.firstIndex(of: item) {
//                self?.filledList.remove(at: index)
//            }
//            completion(false)
//        }
//    
//        deleteAction.image = UIImage(systemName: "trash.fill")
//    
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
    
}
