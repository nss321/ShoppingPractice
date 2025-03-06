//
//  WishListViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 3/6/25.
//

import Foundation

import RealmSwift
import RxCocoa
import RxSwift

final class WishListViewModel: ViewModel {
    struct Input {
        let searchButtonClicked: ControlEvent<Void>
        let searchBarText: ControlProperty<String?>
        let itemSelect: ControlEvent<IndexPath>
    }
    struct Output {
        let storedWishList: Driver<[WishList]>
        let reload: Driver<Void>
    }
    
    private var id: ObjectId
    private(set) var list: List<WishListScheme>
    private(set) var navTitle: String
    private let disposeBag = DisposeBag()
    private let repository: WishListRepository = WishListTableRepository()
    private let folderRepository: FolderRepository = FolderTableRepository()
    
    init(id: ObjectId, list: List<WishListScheme>, navTitle: String) {
        self.id = id
        self.list = list
        self.navTitle = navTitle
    }
    
    func transform(input: Input) -> Output {
        let wishListList = BehaviorRelay(value: [WishList]())
        let reload = PublishRelay<Void>()
        
        Observable.of(list)
            .compactMap { $0 }
            .withUnretained(self)
            .map { owner, scheme in
                return owner.makeWishListList(data: scheme)
            }
            .bind(to: wishListList)
            .disposed(by: disposeBag)
        
        input.searchButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchBarText.orEmpty)
//            .distinctUntilChanged()
            .bind(with: self) { owner, text in
                owner.createNewRow(text: text)
                wishListList.accept(owner.makeWishListList(data: owner.list))
            }
            .disposed(by: disposeBag)
        
        input.itemSelect
            .bind(with: self) { owner, index in
                let item = owner.list[index.item]
                owner.repository.deleteItem(data: item)
                // TODO: 마지막 셀 삭제 시 index out of range 에러 해결
                if owner.list.count == 0 {
//                    wishListList.accept([])
//                    reload.accept(())
                } else {
                    wishListList.accept(owner.makeWishListList(data: owner.list))
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            storedWishList: wishListList.asDriver(), reload: reload.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    private func createNewRow(text: String) {
        let folder = folderRepository.fetchAll().where { folder in
            return folder.id == id
        }.first!
        
        repository.createItem(folder: folder, text: text)
    }
    
    private func makeWishListList(data: List<WishListScheme>) -> [WishList] {
        return data.isEmpty ? [] : Array(data).map { WishList(id: $0.id, title: $0.name) }
    }
}

