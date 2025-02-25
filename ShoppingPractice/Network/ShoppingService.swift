//
//  ShoppingService.swift
//  ShoppingPractice
//
//  Created by BAE on 1/16/25.
//

import UIKit
import Alamofire

enum SortBy: String {
    case sim = "sim"
    case date = "date"
    case asc = "asc"
    case dsc = "dsc"
    
    var filter: String {
        return rawValue
    }
}

enum SearchRequest {
    case basic(keyword: String)
    case sorted(keyword: String, sortby: SortBy = .sim, startAt: Int = 1)

    var endpoint: URL {
        switch self {
        case .basic(let keyword):
            return URL(string: Urls.basic(keyword: keyword))!
        case let .sorted(keyword, sortby, startAt):
            return URL(string: Urls.sortBy(keyword: keyword, sortby: sortby, startAt: startAt))!
        }
    }
    
    var header: HTTPHeaders {
        return [
            "X-Naver-Client-Id" : APIKey.naverClientId,
            "X-Naver-Client-Secret" : APIKey.naverClientSecret
            ]
    }

    var method: HTTPMethod {
        return .get
    }
}

class ShoppingService {
    static let shared = ShoppingService()
    
    func callSearchReQuest<T: Decodable>(api: SearchRequest, type: T.Type, completion: @escaping(T) -> Void) {
        AF.request(api.endpoint,
                   method: api.method,
                   headers: api.header)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completion(value)
                break
            case .failure(let error):
                dump(error)
            }
        }
    }
    func callSearchAPI<T: Decodable>(api: SearchRequest, type: T.Type, completion: @escaping(T) -> Void) {
        AF.request(api.endpoint,
                   method: api.method,
                   headers: api.header)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completion(value)
                break
            case .failure(let error):
                dump(error)
            }
        }
        
        
    }
    
    
}
