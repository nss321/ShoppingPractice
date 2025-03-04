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
    private let searchBar = UISearchBar()
    
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
        [collectionView].forEach { view.addSubview($0) }
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
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
            width: Int(UIScreen.main.bounds.width - 12 * 3) / 2,
            height: Int(UIScreen.main.bounds.height) / 3)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        return layout
    }
}
