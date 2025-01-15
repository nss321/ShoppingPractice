//
//  ViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit
import SnapKit
import Then
import Alamofire

class ViewController: UIViewController, ViewConfig {
    
    private let searchBar = UISearchBar()
    
    var shoppingItemsAndTotal: Merchandise = Merchandise(total: 0, items: []) {
        didSet {
            print("didset")
//            print("shopping item:", self.shoppingItems)
//            let vc = ShoppingListViewController()
//            vc.shoppingItems = self.shoppingItems
//            vc.navigationItem.title = searchBar.searchTextField.text
//            self.navigationController?.pushViewController(vc, animated: true)
            self.pushShoppingListViewController(items: self.shoppingItemsAndTotal, navTitle: searchBar.searchTextField.text!)
        }
    }
    
    var lastSearched = ""
    var lastUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configHierarchy()
        configLayout()
        configView()
//        callRequest()
    }
    
    func configHierarchy() {
        view.addSubview(searchBar)
    }
    
    func configLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    func configView() {
        searchBar.do {
            $0.delegate = self
            $0.placeholder = "검색하세요."
        }
    }
    
    func callRequest(text: String) {
        let url = Urls.naverShoppingWithKeywordWithParams(
            keyword: text,
            params: [.display:"100"])
        
        let header: HTTPHeaders = [
            "X-Naver-Client-Id" : APIKey.naverClientId,
            "X-Naver-Client-Secret" : APIKey.naverClientSecret
        ]
        AF.request(url,
                   method: .get,
                   headers: header
        )
        .validate()
        .responseDecodable(of: Merchandise.self) { response in
            switch response.result {
            case .success(let value):
                dump(value.items)
                if value.items.isEmpty {
                    self.showAlert(title: "검색 결과", message: "검색 결과가 없습니다.", handler: nil)
                } else {
                    self.lastUrl = url
                    self.shoppingItemsAndTotal = value
                }
            case .failure(let error):
                print(error)
            }
        }
//        .responseString { value in
//            dump(value)
//        }
    }
    
    func pushShoppingListViewController(items: Merchandise, navTitle: String) {
        print(#function)
        let vc = ShoppingListViewController()
        vc.shoppingItemsAndTotal = items
        vc.requestedUrl = lastUrl
        vc.navigationItem.titleView = UILabel().then {
            $0.text = navTitle
            $0.font = .systemFont(ofSize: 16, weight: .black)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function,"입력된 문자열(\(searchBar.text!)")
        view.endEditing(true)
        if let text = searchBar.text {
            if text == lastSearched {
                pushShoppingListViewController(items: shoppingItemsAndTotal, navTitle: text)
            } else {
                let trimmedText = text.filter({!$0.isWhitespace})
                if  trimmedText.isEmpty  {
                    showAlert(title: "공백", message: "공백은 검색할 수 없습니다.", handler: nil)
                } else if trimmedText.count < 2 {
                    showAlert(title: "검색어", message: "검색어는 2글자 이상 입력해주세요.", handler: nil)
                } else {
                    callRequest(text: text)
                    lastSearched = text
                }
            }
        }
    }
}

/*
 1. 뷰컨에 서치바 올림
 2. 서치바에서 검색 시 해당 키워드로
    2.1. 냅바 타이틀 변경
    2.2. 네이버쇼핑 API 호출
 3. 서치바는 2글자 이상 입력받는 조건
 4. 정확도, 날짜순 등 필터 정렬
 5. 각 아이템 별 좋아요 버튼
 
 */
