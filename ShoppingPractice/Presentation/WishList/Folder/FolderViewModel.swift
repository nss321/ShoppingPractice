//
//  FolderViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import RealmSwift
import RxCocoa
import RxSwift

final class FolderViewModel: ViewModel {
    struct Input {
        
    }
    struct Output {
        let storedFolder: Driver<[Folder]>
    }
    
    private let disposeBag = DisposeBag()
    private var list: Results<FolderScheme>!
    private let repository: FolderRepository = FolderTableRepository()
    
    init() {
        list = repository.fetchAll()
    }
    
    func transform(input: Input) -> Output {
        let folders = BehaviorRelay(value: [Folder]())
        
        Observable.just(list)
            .compactMap { $0 }
            .map { scheme in
                return Array(scheme).map {
                    Folder(
                        id: $0.id,
                        name: $0.name,
                        count: $0.items.count
                    )
                }
            }
            .bind(to: folders)
            .disposed(by: disposeBag)
        
        
        return Output(storedFolder: folders.asDriver())
    }
    
    func id(index: Int) -> ObjectId {
        return list[index].id
    }
    
    func list(index: Int) -> List<WishListScheme> {
        return list[index].items
    }
    
    func title(index: Int) -> String {
        return list[index].name
    }
    
    
}

