//
//  UserDefaultsManager.swift
//  ShoppingPractice
//
//  Created by BAE on 2/27/25.
//

/*
 1. 프로퍼티 래퍼를 이용한 유저디폴트 매니저
 2. 유저디폴트 단에서 Set sequence로 return
 */

import Foundation

//final class UserDefaultsManager {
//    static let shared = UserDefaultsManager()
//    private init () { }
//    
//    enum Keys: String {
//        case like
//    }
//
//    var like: [String] {
//        get {
//            return UserDefaults.standard.stringArray(forKey: Keys.like.rawValue) ?? []
//        }
//        
//        set {
//            UserDefaults.standard.set(newValue, forKey: Keys.like.rawValue)
//        }
//    }
//}

enum UserDefaultsManager {
    enum Keys: String {
        case like
    }
    
    static var like: Set<String> {
        get {
            return Set(UserDefaults.standard.stringArray(forKey: Keys.like.rawValue) ?? [])
        }
        
        set {
            UserDefaults.standard.set(Array(newValue), forKey: Keys.like.rawValue)
        }
    }
    
    @LikeList(key: Keys.like.rawValue, defaultValue: Set<String>())
    static var likeList
}

@propertyWrapper
struct LikeList {
    let key: String
    let defaultValue: Set<String>
    
    var wrappedValue: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }
}
