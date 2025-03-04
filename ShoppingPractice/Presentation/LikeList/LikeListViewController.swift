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
    private var data: Results<LikedGoodsRealmModel>!
    private let realm = try! Realm()
    private let viewModel = LikeListViewModel()
    
    override func bind() {
        data = realm.objects(LikedGoodsRealmModel.self)
        
        BehaviorRelay(value: data)
            .compactMap {
                print($0)
                return $0
            }
            .bind(to: collectionView.rx.items(cellIdentifier: ShoppingListCollectionViewCell.id, cellType: ShoppingListCollectionViewCell.self)) ({ _, element, cell in
                let item = MerchandiseInfo(id: element.id, title: element.title, image: element.image, price: element.price, mall: element.mall, link: element.link)
                cell.config(item: item)
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 12
                print(item)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(MerchandiseInfo.self)
            .bind(with: self) { owner, item in
                print(item.image)
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
