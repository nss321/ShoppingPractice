//
//  FolderRepository.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import RealmSwift

protocol FolderRepository {
    func createItem(name: String)
    func fetchAll() -> Results<FolderScheme>
}

// MARK: 싱글톤 객체로 쓰면???
final class FolderTableRepository: FolderRepository {
    
    private let realm = try! Realm()
    
    func getFilePath() {
        print(realm.configuration.fileURL!)
    }
    
    func createItem(name: String) {
        do {
            try realm.write {
                let folder = FolderScheme(name: name)
                realm.add(folder)
            }
        } catch {
            print("폴더 추가 실패")
        }
    }
    
    func fetchAll() -> Results<FolderScheme> {
        return realm.objects(FolderScheme.self)
    }
    
}

