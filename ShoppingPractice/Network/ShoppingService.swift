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
                   headers: api.header) { request in
            // 반복적인 네트워크 요청을 줄이기 위해서 사용
            // Device Network Condtion을 very poor로 두고 테스트 했을때 의도한 대로 동작
            // 캐시된 데이터를 뱉어도 스테이터스 코드는 200을 밷는다??
            // 응답 전체를 캐싱해서 그럴까?
            // TODO: 네트워크 요청이 길어질 때 처리(10초, 30초 등)
            request.cachePolicy = .returnCacheDataElseLoad
        }
        .responseDecodable(of: T.self) { response in
//            print(response.response?.statusCode)
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
