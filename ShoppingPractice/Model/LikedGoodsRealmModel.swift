//
//  LikedGoodsRealmModel.swift
//  ShoppingPractice
//
//  Created by BAE on 3/4/25.
//

import RealmSwift

final class LikedGoodsRealmModel: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var image: String
    @Persisted var price: String
    @Persisted var mall: String
    @Persisted var link: String
    
    convenience init(id: String, title: String, image: String, price: String, mall: String, link: String) {
        self.init()
        self.id = id
        self.title = title
        self.image = image
        self.price = price
        self.mall = mall
        self.link = link
    }
}

