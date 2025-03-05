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
    
//    @Persisted var detail: List<>
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
