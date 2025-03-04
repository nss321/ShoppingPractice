//
//  LikeListViewModel.swift
//  ShoppingPractice
//
//  Created by BAE on 3/4/25.
//

import RealmSwift
import RxCocoa
import RxSwift

final class LikeListViewModel: ViewModel {
    struct Input {
        
    }
    
    struct Output {
        let data: Driver<[MerchandiseInfo]>
    }
    
    private let disposeBag = DisposeBag()
    private let data: Results<LikedGoodsRealmModel>
    private let realm = try! Realm()
    
    init() {
        self.data = realm.objects(LikedGoodsRealmModel.self)
    }
    
    func transform(input: Input) -> Output {
        let storedData = BehaviorRelay(value: [MerchandiseInfo]())
        
        BehaviorRelay(value: data)
            .compactMap { realmData in
                let value = Array(realmData).map {
                    MerchandiseInfo(
                        id: $0.id,
                        title: $0.title,
                        image: $0.image,
                        price: $0.price,
                        mall: $0.mall,
                        link: $0.link)
                }
                return value
            }
            .bind(with: self) { owner, value in
                storedData.accept(value)
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(data: storedData.asDriver())
    }
}
