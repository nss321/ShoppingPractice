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
        let toastMessage: Driver<String>
    }
    
    private let disposeBag = DisposeBag()
    private let item: MerchandiseInfo
    private let realm = try! Realm()
    private var data: Results<LikedGoodsRealmModel>
    
    init(item: MerchandiseInfo) {
        self.item = item
        self.data = realm.objects(LikedGoodsRealmModel.self)
    }
    
    func transform(input: Input) -> Output {
        let itemObservable = Observable.just(item)
        let isLiked = BehaviorRelay(value: false)
        let toastMessage = PublishRelay<String>()
        
        input.buttonConfig
            .bind(with: self) { owner, _ in
                isLiked.accept(owner.loadLikeFromRealm())
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .bind(with: self) { owner, _ in
                isLiked.accept(owner.toggleLikeFromRealm())
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTap
            .withLatestFrom(itemObservable)
            .map { item -> String in
                let title = item.title
                let endIndex = title.index(title.startIndex, offsetBy: 10)
                return String(title[..<endIndex])
            }
            .bind(with: self) { owner, text in
                print(text)
                if owner.loadLikeFromRealm() {
                    toastMessage.accept("\(text)... 좋아요")
                } else {
                    toastMessage.accept("\(text)... 삭제")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            isLiked: isLiked.asDriver(),
            toastMessage: toastMessage.asDriver(onErrorJustReturn: "")
        )
    }
    
    // MARK: Using UserDefaults, can only item's id
//    private func toggleLike() -> Bool {
//        var isLiked: Bool
//        var origin = UserDefaultsManager.likeList
//        if origin.contains(item.id) {
//            origin.remove(item.id)
//            isLiked = false
//        } else {
//            origin.insert(item.id)
//            isLiked = true
//        }
//        UserDefaultsManager.likeList = origin
//        return isLiked
//    }
//    private func loadLike() -> Bool {
//        return UserDefaultsManager.likeList.contains(item.id)
//    }
    
    // MARK: Using Realm, but needs to be refactored.
    private func toggleLikeFromRealm() -> Bool {
        // TODO: Realm에 insert/delete
        // 1. realm 상에 존재 하는가?
        // 2. 하면? -> 삭제
        // 3. 안하면? -> 삽입
        // 전체를 다 가져와서 있으면 삭제 없으면 추가?
        var isLiked = false
        
        // realm 내의 row를 지울 땐, 'realm에서 가져온 데이터'를 지워야함.
        // 그렇지 않으면 -> 크래시
        guard let targetItem = data.first(where: { $0.id == item.id }) else {
            // 없을 경우
            let targetItem = LikedGoodsRealmModel(value: [
                "id": item.id,
                "title": item.title,
                "image": item.image,
                "price": item.price,
                "mall": item.mall,
                "link": item.link
            ])
            
            do {
                try realm.write {
                    realm.add(targetItem)
                    isLiked = true
                    print("add success to realm >>>", targetItem)
                }
            } catch {
                print("failed to delete \(targetItem.id) from realm")
            }
            return isLiked
        }
        
        // 있을 경우
        do {
            try realm.write {
                realm.delete(targetItem)
                isLiked = false
                print("delete success to realm >>>", targetItem)
            }
        } catch {
            print("failed to delete \(targetItem.id) from realm")
        }
        
        return isLiked
    }
    
    private func loadLikeFromRealm() -> Bool {
        let targetId = item.id
        let storedIds = data.map{ $0.id }
        print(#function, storedIds.contains(targetId))
        return storedIds.contains(targetId)
    }
}
