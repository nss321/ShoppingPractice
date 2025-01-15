//
//  ShoppingListViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit
import Alamofire
import Kingfisher
import Then
import SnapKit


enum SortBy: String {
    case sim = "sim"
    case date = "date"
    case asc = "asc"
    case dsc = "dsc"
    
    var filter: String {
        return rawValue
    }
}

class ShoppingListViewController: UIViewController, ViewConfig {
    
    /*
     frame, layout init 안해주면
     UICollectionView must be initialized with a non-nil layout parameter
     뿜으면서 터짐
     */
    private let resultCntLabel = UILabel()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let filterStack = UIStackView()
    private let accuracyFilter = UIButton()
    private let dateFilter = UIButton()
    private let hPriceFilter = UIButton()
    private let lPriceFilter = UIButton()

    var shoppingItemsAndTotal: Merchandise = Merchandise(total: 0, items: []) {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var _requestedUrl: String = ""
    
    var requestedUrl: String {
        get {
            return _requestedUrl
        }
        set {
            _requestedUrl = newValue
        }
    }
    
    let spacing: CGFloat = 12
    
    var buttonsState = Array(repeating: false, count: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configHierarchy()
        configLayout()
        configView()
        configNavigation()
    }
    
    func configHierarchy() {
        print(#function)
        [resultCntLabel, filterStack, collectionView].forEach { view.addSubview($0) }
        [accuracyFilter, dateFilter, hPriceFilter, lPriceFilter].forEach { filterStack.addArrangedSubview($0) }
    }
    
    func configLayout() {
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
    
    func configView() {
        print(#function)
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
        
//        accuracyFilter.do {
//            var config = UIButton.Configuration.plain()
//            var attribString = AttributedString("정확도")
//            attribString.font = .system(size: 16)
//            attribString.foregroundColor = .white
//            config.attributedTitle = attribString
//            config.background.backgroundColor = .black
//            config.background.strokeWidth = 1
//            config.background.strokeColor = .white
//            
//            $0.configuration = config
//        }
//        dateFilter.do {
//            var config = accuracyFilter.configuration!.updated(for: accuracyFilter)
//            var attribString = AttributedString("정확도")
//            attribString.font = .system(size: 16)
//            attribString.foregroundColor = .white
//            config.attributedTitle = attribString
//            $0.configuration = config
//        }
//        
//        hPriceFilter.do {
//            var config = UIButton.Configuration.plain()
//            var attribString = AttributedString("정확도")
//            attribString.font = .system(size: 16)
//            attribString.foregroundColor = .white
//            config.attributedTitle = attribString
//            config.background.backgroundColor = .black
//            config.background.strokeWidth = 1
//            config.background.strokeColor = .white
//
//            $0.configuration = config
//        }
//        lPriceFilter.do {
//            var config = UIButton.Configuration.plain()
//            var attribString = AttributedString("정확도")
//            attribString.font = .system(size: 16)
//            attribString.foregroundColor = .white
//            config.attributedTitle = attribString
//            config.background.backgroundColor = .black
//            config.background.strokeWidth = 1
//            config.background.strokeColor = .white
//
//            $0.configuration = config
//        }
        //
        
        accuracyFilter.do {
            $0.setAttributedTitle(NSAttributedString(string: "정확도", attributes: [.foregroundColor : UIColor.white]), for: .normal)
            $0.backgroundColor = .black
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
            $0.addAction(UIAction(handler: { _ in
                self.callRequest(sortedBy: .sim)
            }), for: .touchUpInside)
        }
        dateFilter.do {
            $0.setAttributedTitle(NSAttributedString(string: "날짜순", attributes: [.foregroundColor : UIColor.white]), for: .normal)
            $0.backgroundColor = .black
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
            $0.addAction(UIAction(handler: { _ in
                self.callRequest(sortedBy: .date)
            }), for: .touchUpInside)
        }
        hPriceFilter.do {
            $0.setAttributedTitle(NSAttributedString(string: "가격높은순", attributes: [.foregroundColor : UIColor.white]), for: .normal)
            $0.backgroundColor = .black
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
            $0.addAction(UIAction(handler: { _ in
                self.callRequest(sortedBy: .dsc)
            }), for: .touchUpInside)
        }
        lPriceFilter.do {
            $0.setAttributedTitle(NSAttributedString(string: "가격낮은순", attributes: [.foregroundColor : UIColor.white]), for: .normal)
            $0.backgroundColor = .black
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
            $0.addAction(UIAction(handler: { _ in
                self.callRequest(sortedBy: .asc)
            }), for: .touchUpInside)
        }
        
        
        collectionView.do {
            $0.delegate = self
            $0.dataSource = self
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
    
    @objc
    func popThisViewController(_ sender: UIBarButtonItem) {
        print(#function)
        navigationController?.popViewController(animated: true)
    }
    
    
    func callRequest(sortedBy: SortBy) {
        var url = requestedUrl
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
        
        print(url)
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
                self.shoppingItemsAndTotal = value
            case .failure(let error):
                print(error)
            }
        }
//        .responseString { value in
//            dump(value)
//        }
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
//        cell.layer.borderColor = UIColor.red.cgColor
//        cell.layer.borderWidth = 1
//        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(#function)
        return CGSize(
            width: Int(UIScreen.main.bounds.width - spacing * 3) / 2,
            height: Int(UIScreen.main.bounds.height) / 3)
        
//        return CGSize(
//            width: 100,
//            height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        spacing
    }
    
}
