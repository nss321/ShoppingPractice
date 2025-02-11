//
//  Merchandise.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

struct Merchandise: Decodable {
    let total: Int
    var items: [MerchandiseInfo]
}

struct MerchandiseInfo: Decodable {
    let title: String
    let image: String
    let price: String
    let mall: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case image
        case price = "lprice"
        case mall = "mallName"
    }
}

struct ShoppingAPIError: Decodable {
    let errorMessage: String
    let errorCode: String
}
