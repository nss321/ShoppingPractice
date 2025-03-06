//
//  WishListRepository.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import Foundation

import RealmSwift

protocol WishListRepository {
    func fetchAll(folder: FolderScheme) -> Results<WishListScheme>
    func createItem(folder: FolderScheme, text: String)
    func deleteItem(data: WishListScheme)
    func updateItem(data: WishListScheme, text: String)
}

final class WishListTableRepository: WishListRepository {
    
    private let realm = try! Realm()
    
    func fetchAll(folder: FolderScheme) -> Results<WishListScheme> {
        return realm.objects(WishListScheme.self)
            .where { $0.folder == folder }
    }
    
    func createItem(folder: FolderScheme, text: String) {
        do {
            try realm.write {
                let data = WishListScheme(id: UUID(), name: text)
                folder.items.append(data)
                realm.add(data)
                print("렐름 저장 왈름", data)
            }
        } catch {
            print("렐름 저장 낼름ㅜㅜ")
        }
    }
    
    func deleteItem(data: WishListScheme) {
        do {
            try realm.write {
                print("다음 데이터를 삭제", data)
                realm.delete(data)
                print("렐름 삭제 왈름", data)
            }
        } catch {
            print("렐름 삭제 낼름ㅜㅜ")

        }
    }
    
    // MARK: 얼럿 띄워서 텍스트 입력
    func updateItem(data: WishListScheme, text: String) {
        do {
            try realm.write {
                realm.create(WishListScheme.self, value: [
                    "name": text
                ], update: .modified)
                print("렐름 수정 왈름", data)
            }
        } catch {
            print("렐름 수정 실패")
        }
    }
}
