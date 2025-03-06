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
        let itemSelect: ControlEvent<WishListScheme>
    }
    struct Output {
        let storedWishList: Driver<List<WishListScheme>>
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
        print(#function)
        let wishListList = BehaviorRelay(value: list)
        let reload = PublishRelay<Void>()
        
        Observable.just(list)
            .bind(with: self) { owner, list in
                wishListList.accept(list)
            }
            .disposed(by: disposeBag)
        
        input.searchButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchBarText.orEmpty)
            .bind(with: self) { owner, text in
                owner.createNewRow(text: text)
                wishListList.accept(owner.list)
            }
            .disposed(by: disposeBag)
        
        input.itemSelect
            .bind(with: self) { owner, item in
                owner.repository.deleteItem(data: item)
                reload.accept(())
                wishListList.accept(owner.list)
            }
            .disposed(by: disposeBag)

        return Output(
            storedWishList: wishListList.asDriver(onErrorDriveWith: .empty()), reload: reload.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    private func createNewRow(text: String) {
        let folder = folderRepository.fetchAll().where { folder in
            return folder.id == id
        }.first!
        
        repository.createItem(folder: folder, text: text)
    }
}

