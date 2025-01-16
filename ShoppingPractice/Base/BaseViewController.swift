//
//  BaseViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/17/25.
//

import UIKit
import SnapKit
import Then

class BaseViewController: UIViewController {
    
    var shoppingItemsAndTotal: Merchandise = Merchandise(total: 0, items: []) { didSet { } }
    
    let searchBar = UISearchBar()
    var lastSearched = ""
    
    
    let resultCntLabel = UILabel()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let filterStack = UIStackView()
    let accuracyFilter = UIButton()
    let dateFilter = UIButton()
    let hPriceFilter = UIButton()
    let lPriceFilter = UIButton()
    var lastFilter: SortBy = .sim
    var page = 1
    var currentPage: Int {
        return shoppingItemsAndTotal.items.count
    }
    let spacing: CGFloat = 12
    var buttonsState = Array(repeating: false, count: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func configureHierarchy() {
        view.addSubview(searchBar)

    } 
    
    func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    func configureView() {
        searchBar.placeholder = "검색하세요."
        
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
        }
        dateFilter.do {
            $0.configuration = makeButtonConfig(title: "날짜순")
        }
        hPriceFilter.do {
            $0.configuration = makeButtonConfig(title: "가격높은순")
        }
        lPriceFilter.do {
            $0.configuration = makeButtonConfig(title: "가격낮은순")
        }
        
        collectionView.do {
            $0.register(ShoppingListCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingListCollectionViewCell.id)
        }
    }
    
    func configNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left")!.withTintColor(.white, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(popThisViewController))
    }
    
    func makeButtonConfig(title: String) -> UIButton.Configuration {
        var attribString = AttributedString(title)
        attribString.font = .systemFont(ofSize: 16)
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = attribString
        
        // plain 버튼의 글자색은 baseForegroundColor로 변경
        config.baseForegroundColor = .white
        config.background.backgroundColor = .black
        config.background.strokeWidth = 1
        config.background.strokeColor = .white
        
        return config
    }
    
    func makeUIAction(sortedBy: SortBy) -> UIAction {
        return UIAction { _ in
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            if self.lastFilter == sortedBy {
                return
            } else {
                ShoppingService.shared.callSearchRequest(text: self.lastSearched, sortedBy: sortedBy) {
                    self.shoppingItemsAndTotal = $0
                }
                self.lastFilter = sortedBy
            }
        }
    }
    
    @objc
    func popThisViewController(_ sender: UIBarButtonItem) {
        print(#function)
        navigationController?.popViewController(animated: true)
    }
}
