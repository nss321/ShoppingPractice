//
//  CustomLikeButtonViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/28/25.
//

import RealmSwift
import RxSwift
import RxCocoa

final class CustomLikeButtonViewModel: ViewModel {
    struct Input {
        let buttonConfig: Observable<Void>
        let likeButtonTap: ControlEvent<Void>
    }
    struct Output {
        let isLiked: Driver<Bool>
    }
    private let disposeBag = DisposeBag()
    private let realm = try! Realm()
    let item: MerchandiseInfo
    
    init(item: MerchandiseInfo) {
        self.item = item
    }
    
    func transform(input: Input) -> Output {
        let isLiked = BehaviorRelay(value: false)
        
        input.buttonConfig
            .bind(with: self) { owner, _ in
                isLiked.accept(owner.loadLike())
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .bind(with: self) { owner, _ in
                isLiked.accept(owner.toggleLike())
                // TODO: Realm에 insert/delete
                // 1. realm 상에 존재 하는가?
                // 2. 하면? -> 삭제
                // 3. 안하면? -> 삽입
                
                // 전체를 다 가져와서 있으면 삭제 없으면 추가?
                
                let data = LikedGoodsRealmModel(value: [
                    "id": owner.item.id,
                    "title": owner.item.title,
                    "image": owner.item.image,
                    "price": owner.item.price,
                    "mall": owner.item.mall,
                    "link": owner.item.link
                ])
                
                do {
                    try owner.realm.write {
                        owner.realm.add(data)
                        print("add success to realm >>>", data)
                    }
                } catch {
                    print("add failed to realm >>>", data)
                }
                
                print(UserDefaultsManager.likeList)
            }
            .disposed(by: disposeBag)
        
        return Output(
            isLiked: isLiked.asDriver()
        )
    }
    
    private func toggleLike() -> Bool {
        var isLiked: Bool
        var origin = UserDefaultsManager.likeList
        if origin.contains(item.id) {
            origin.remove(item.id)
            isLiked = false
        } else {
            origin.insert(item.id)
            isLiked = true
        }
        UserDefaultsManager.likeList = origin
        return isLiked
    }
    
    private func loadLike() -> Bool {
        return UserDefaultsManager.likeList.contains(item.id)
    }
    
    private func toggleLike2() -> Bool {
        // TODO: Realm에 insert/delete
        // 1. realm 상에 존재 하는가?
        // 2. 하면? -> 삭제
        // 3. 안하면? -> 삽입
        // 전체를 다 가져와서 있으면 삭제 없으면 추가?
        let data = LikedGoodsRealmModel(value: [
            "id": item.id,
            "title": item.title,
            "image": item.image,
            "price": item.price,
            "mall": item.mall,
            "link": item.link
        ])
        
        do {
            try realm.write {
                realm.add(data)
                print("add success to realm >>>", data)
            }
        } catch {
            print("add failed to realm >>>", data)
        }
        
        return true
    }
    
}
