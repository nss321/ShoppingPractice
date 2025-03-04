//
//  Merchandise.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

struct Merchandise: Decodable {
    let total: Int
    var items: [MerchandiseInfo]
    
    static func empty() -> Merchandise {
        return Merchandise.init(total: 0, items: [])
    }
}

struct MerchandiseInfo: Decodable, Equatable {
    let id: String
    let title: String
    let image: String
    let price: String
    let mall: String
    let link: String
    
    enum CodingKeys: String, CodingKey {
        case id = "productId"
        case title
        case image
        case price = "lprice"
        case mall = "mallName"
        case link
    }
    
    static func empty() -> Self {
        return MerchandiseInfo(id: "", title: "", image: "", price: "", mall: "", link: "")
    }
}

struct ShoppingAPIError: Decodable {
    let errorMessage: String
    let errorCode: String
}
