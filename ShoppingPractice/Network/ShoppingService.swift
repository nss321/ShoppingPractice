//
//  ShoppingService.swift
//  ShoppingPractice
//
//  Created by BAE on 1/16/25.
//

import UIKit
import Alamofire

class ShoppingService {
    static let shared = ShoppingService()
    
    private let header: HTTPHeaders = [
        "X-Naver-Client-Id" : APIKey.naverClientId,
        "X-Naver-Client-Secret" : APIKey.naverClientSecret
    ]
    
    // TODO: 범용 리퀘스트 메서드로 분리할 수 없는지 고민해보기
    /*
    private func getRequest(url: String, completion: (@escaping(Merchandise)->Merchandise)) {
        AF.request(url,
                   method: .get,
                   headers: header
        )
        .validate()
        .responseDecodable(of: Merchandise.self) { response in
            switch response.result {
            case .success(let value):
                dump(value.items)
                completion(value)
            case .failure(let error):
                print(#function, error)
            }
        }
    }
    
    private func callSearchRequest(text: String) -> Merchandise {
        var merchandise = Merchandise(total: 0, items: [])
        let url = Urls.naverShoppingWithKeywordWithParams(
            keyword: text,
            params: [.display : "10"])
        
        getRequest(url: url) { Merchandise in
            print(#function)
            dump(Merchandise)
            merchandise = Merchandise
            return merchandise
        }
        //        print(merchandise)
        return merchandise
    }
     */
    
    
    func callSearchRequest(text: String, completion: @escaping(Merchandise)->Void){
        let url = Urls.naverShoppingWithKeywordWithParams(
            keyword: text,
            params: [.display : "10"])
        
        AF.request(url, method: .get, headers: header).responseDecodable(of: Merchandise.self) { response in
            switch response.result {
            case .success(let value):
                dump(value)
                completion(value)
            case .failure(let error):
                print(#function, error)
            }
        }
    }
    
    func callSearchRequest(text: String, sortedBy: SortBy, completion: @escaping(Merchandise)->Void){
        var url = Urls.naverShoppingWithKeywordWithParams(
            keyword: text,
            params: [.display : "100"])
        url.append(naverParams.sort.param)
        
        switch sortedBy {
        case .asc:
            url.append(sortedBy.filter)
            break
        case .date:
            url.append(sortedBy.filter)
            break
        case .dsc:
            url.append(sortedBy.filter)
            break
        case .sim:
            url.append(sortedBy.filter)
            break
        }
        
        AF.request(url, method: .get, headers: header).responseDecodable(of: Merchandise.self) { response in
            switch response.result {
            case .success(let value):
                dump(value)
                completion(value)
            case .failure(let error):
                print(error)
            }
        }
    }
}
