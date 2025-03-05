//
//  WishListViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 3/6/25.
//

import RealmSwift
import RxCocoa
import RxSwift

final class WishListViewModel: ViewModel {
    struct Input {
        let searchButtonClicked: ControlEvent<Void>
        let searchBarText: ControlProperty<String?>
    }
    struct Output {
        let storedWishList: Driver<[WishList]>
        let reload: Driver<Void>
    }
    
    private var id: ObjectId
    private(set) var navTitle: String
    private var list: List<WishListScheme>
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
            .map { scheme in
                return Array(scheme).map {
                    WishList(id: $0.id, title: $0.name)
                }
            }
            .bind(to: wishListList)
            .disposed(by: disposeBag)
        
        input.searchButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchBarText.orEmpty)
            .distinctUntilChanged()
            .bind(with: self) { owner, text in
                owner.createNewRow(text: text)
                reload.accept(())
            }
            .disposed(by: disposeBag)
        
        
        return Output(storedWishList: wishListList.asDriver(),
                      reload: reload.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    private func createNewRow(text: String) {
        let folder = folderRepository.fetchAll().where { folder in
            return folder.id == id
        }.first!
        
        repository.createItem(folder: folder, text: text)
    }
    
}

