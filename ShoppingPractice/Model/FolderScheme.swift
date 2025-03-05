//
//  Folder.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import RealmSwift

final class FolderScheme: Object {
    @Persisted var id: ObjectId
    @Persisted var name: String
    
    @Persisted var items: List<WishListScheme>
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
