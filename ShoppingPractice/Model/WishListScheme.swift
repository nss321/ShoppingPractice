//
//  WishListScheme.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import Foundation

import RealmSwift

final class WishListScheme: Object {
    @Persisted var id: UUID
    @Persisted var name: String
    @Persisted var content: String?
    
    @Persisted(originProperty: "items") var folder: LinkingObjects<FolderScheme>
    
    convenience init(id: UUID, name: String, content: String? = nil) {
        self.init()
        self.id = id
        self.name = name
        self.content = content
    }
}
