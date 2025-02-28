//
//  UserDefaultsManager.swift
//  ShoppingPractice
//
//  Created by BAE on 2/27/25.
//

/*
 1. 프로퍼티 래퍼를 이용한 유저디폴트 매니저
 2.
 */

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init () { }
    
    enum Keys: String {
        case like
    }

    var like: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: Keys.like.rawValue) ?? []
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.like.rawValue)
        }
    }
}
