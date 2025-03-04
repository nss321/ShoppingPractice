//
//  LikeListViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 3/4/25.
//

import UIKit

import RealmSwift
import RxSwift
import RxCocoa
import SnapKit

final class LikeListViewController: BaseViewController {
    
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout())
        view.register(ShoppingListCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingListCollectionViewCell.id)
        view.backgroundColor = .clear
        return view
    }()
    private let searchBar = {
        let view = UISearchBar()
        view.placeholder = "검색하세요."
        view.barTintColor = .systemGroupedBackground
        view.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private var data: Results<LikedGoodsRealmModel>!
    private let realm = try! Realm()
    private let viewModel = LikeListViewModel()
    
    override func bind() {
        let input = LikeListViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.data
            .drive(collectionView.rx.items(cellIdentifier: ShoppingListCollectionViewCell.id, cellType: ShoppingListCollectionViewCell.self))  { _, element, cell in
                cell.config(item: element)
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 12
            }
            .disposed(by: disposeBag)
        
        Observable
            .zip (
                collectionView.rx.modelSelected(MerchandiseInfo.self),
                collectionView.rx.itemSelected
            )
            .bind(with: self) { owner, value in
                let vc = DetailWebViewController()
                vc.viewModel = DetailWebViewModel(item: value.0)
                vc.viewModel.completion = {
                    owner.collectionView.reloadItems(at: [value.1])
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configLayout() {
        [searchBar, collectionView].forEach { view.addSubview($0) }
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(smallMargin)
            $0.horizontalEdges.equalToSuperview().inset(smallMargin)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func configNavigation() {
        navigationItem.backButtonTitle = ""
        navigationItem.title = "좋아요 목록"
    }
}

// MARK: Extension
extension LikeListViewController {
    private func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(
            width: Int(UIScreen.main.bounds.width - CGFloat(smallMargin * 3)) / 2,
            height: Int(UIScreen.main.bounds.height) / 3)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = CGFloat(smallMargin)
        layout.minimumInteritemSpacing = CGFloat(smallMargin)
        return layout
    }
}
