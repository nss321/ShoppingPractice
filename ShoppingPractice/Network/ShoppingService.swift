//
//  ShoppingService.swift
//  ShoppingPractice
//
//  Created by BAE on 1/16/25.
//

import Foundation

import Alamofire
import RxSwift
import RxCocoa

enum SortBy: String {
    case sim = "sim" // 정확도
    case date = "date" // 날짜순
    case asc = "asc" // 가격높은순
    case dsc = "dsc" // 가격낮은순
    
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

//400Incorrect query request (잘못된 쿼리요청입니다.)    API 요청 URL의 프로토콜, 파라미터 등에 오류가 있는지 확인합니다.
//SE02        400Invalid display value (부적절한 display 값입니다.)    display 파라미터의 값이 허용 범위의 값(1~100)인지 확인합니다.
//SE03        400Invalid start value (부적절한 start 값입니다.)    start 파라미터의 값이 허용 범위의 값(1~1000)인지 확인합니다.
//SE04        400Invalid sort value (부적절한 sort 값입니다.)    sort 파라미터의 값에 오타가 있는지 확인합니다.
//SE06        400Malformed encoding (잘못된 형식의 인코딩입니다.)    검색어를 UTF-8로 인코딩합니다.
//SE05        404Invalid search api (존재하지 않는 검색 api 입니다.)    API 요청 URL에 오타가 있는지 확인합니다.
//SE99        500System Error (시스템 에러)

enum APIError: String, Error {
    case invalidQuery = "잘못된 쿼리입니다."
    case unauthorizedAccess = "인증되지 않은 토큰입니다."
    case notFound = "잘못된 요청입니다."
    case systemError = "백엔드 잘못입니다."
    case unknownResponse = "알 수 없는 오류입니다."
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
    
    func callSearchAPI<T: Decodable>(api: SearchRequest, type: T.Type) -> Single<Result<T, APIError>> {
        
        return Single.create { value in
            
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
                       .validate(statusCode: 200...299)
                       .responseDecodable(of: T.self) { response in
                           switch response.result {
                           case .success(let result):
                               value(.success(.success(result)))
                               break
                           case .failure(let error):
                               if let status = response.response?.statusCode {
                                   switch status {
                                   case 400:
                                       value(.success(.failure(APIError.invalidQuery)))
                                   case 403:
                                       value(.success(.failure(APIError.unauthorizedAccess)))
                                   case 404:
                                       value(.success(.failure(APIError.notFound)))
                                   case 500:
                                       value(.success(.failure(APIError.systemError)))
                                   default:
                                       value(.success(.failure(APIError.unknownResponse)))
                                   }
                               }
                               dump(error)
                           }
                       }
            return Disposables.create {
                print("통신끝")
            }
        }
    }
}
