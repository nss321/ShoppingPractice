//
//  ShoppingListViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit
import Then
import SnapKit

/*
 ⭐️  17회차   ⭐️
 
 1. 마지막 페이지를 알 수 있는 방법 -> currentPage와 Response의 total을 비교한다?
    1.1 다른 API의 경우에도 isEnd가 없다면,
        - 한 페이지 diplay 개수로 전체 페이지를 구하고, 이를 현재 페이지와 비교
        - 현재 아이템의 인덱스와 전체 아이템의 수 비교
        - 필터를 적용하는 경우 반대 필터의 가장 끝 아이템과 비교하는 방법도 있을 것 같다.
            - 근데 이 방법은 현재 구현에선 어려울 듯 하다. 같은 정렬도의 아이템끼리는 무작위로 나오기 때문
            - 네이버 쇼핑이나, 쿠팡 같은걸 생각하면 기본적인 정렬 옵션(내부적인)이 있다거나 비즈니스 모델에 따라서도
                달라질 것 같다. e.g. 같은 정렬도라면 더 많이 팔린 제품, 가나다 순, 또는 광고 상품 등
 2. Function Type과 Closure 고민해복이
 
 */

enum SortBy: String {
    case sim = "sim"
    case date = "date"
    case asc = "asc"
    case dsc = "dsc"
    
    var filter: String {
        return rawValue
    }
}

class ShoppingListViewController: BaseViewController {
    
    /*
     frame, layout init 안해주면
     UICollectionView must be initialized with a non-nil layout parameter
     뿜으면서 터짐
     */

    override var shoppingItemsAndTotal: Merchandise {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // display를 30으로 두고, currentPage가 28일 떄 프리패치 실행하는 전략
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigation()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func configureHierarchy() {
        print(#function)
        [resultCntLabel, filterStack, collectionView].forEach { view.addSubview($0) }
        [accuracyFilter, dateFilter, hPriceFilter, lPriceFilter].forEach { filterStack.addArrangedSubview($0) }
    }
    
    override func configureLayout() {
        print(#function)
        resultCntLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().inset(12)
        }
        
        filterStack.snp.makeConstraints {
            $0.top.equalTo(resultCntLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.height.equalTo(32)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(filterStack.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func configureView() {
        resultCntLabel.do {
            let formatter = NumberFormatter().then { $0.numberStyle = .decimal }
            let totalResult = formatter.string(for: shoppingItemsAndTotal.total)
            $0.font = .systemFont(ofSize: 15, weight: .heavy)
            $0.textColor = .systemGreen
            $0.text = "\(totalResult ?? "0") 개의 검색 결과"
        }
        
        filterStack.do {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.distribution = .fillProportionally
        }
        
        accuracyFilter.do {
            $0.configuration = makeButtonConfig(title: "정확도")
            $0.addAction(makeUIAction(sortedBy: .sim), for: .touchUpInside)
        }
        
        dateFilter.do {
            $0.configuration = makeButtonConfig(title: "날짜순")
            $0.addAction(makeUIAction(sortedBy: .date), for: .touchUpInside)
        }
        hPriceFilter.do {
            $0.configuration = makeButtonConfig(title: "가격높은순")
            $0.addAction(makeUIAction(sortedBy: .dsc), for: .touchUpInside)
        }
        lPriceFilter.do {
            $0.configuration = makeButtonConfig(title: "가격낮은순")
            $0.addAction(makeUIAction(sortedBy: .asc), for: .touchUpInside)
        }
        
        collectionView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.prefetchDataSource = self
            $0.register(ShoppingListCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingListCollectionViewCell.id)
        }
    }
}

extension ShoppingListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(#function, shoppingItemsAndTotal.items.count)
        return shoppingItemsAndTotal.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(#function)
        let item = shoppingItemsAndTotal.items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShoppingListCollectionViewCell.id, for: indexPath) as! ShoppingListCollectionViewCell
        
        cell.config(item: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(#function)
        return CGSize(
            width: Int(UIScreen.main.bounds.width - spacing * 3) / 2,
            height: Int(UIScreen.main.bounds.height) / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
}

extension ShoppingListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print(#function)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(#function, indexPaths)
        
        
        // 빠르게 스크롤하면 바운스 되는 경우가 있음.
        // TODO: 공식문서 확인
        for item in indexPaths {
            if currentPage - 3 == item.row {
                ShoppingService.shared.callSearchRequest(text: lastSearched, sortedBy: lastFilter, startAt: currentPage) {
                    self.shoppingItemsAndTotal.items.append(contentsOf: $0.items)
                }
            }
            
        }
    }
    
    
}

extension ShoppingListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        print(navigationController?.viewControllers.count ?? 0 )
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
