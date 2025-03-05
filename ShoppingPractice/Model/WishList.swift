//
//  WishList.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import Realm

struct WishList: Hashable {
    let id: UUID
    let title: String
    let content: String?
    
    init(id: UUID, title: String, content: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
    }
}
