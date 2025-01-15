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


class ShoppingListViewController: UIViewController, ViewConfig {
    
    private let resultCntLabel = UILabel()

    var shoppingItemsAndTotal: Merchandise = Merchandise(total: 0, items: []) {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let list = Array(1...20)
    let spacing: CGFloat = 12
    
    
    /*
     frame, layout init 안해주면
     UICollectionView must be initialized with a non-nil layout parameter
     뿜으면서 터짐
     */
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configHierarchy()
        configLayout()
        configView()
        configNavigation()
    }
    
    func configHierarchy() {
        print(#function)
        [resultCntLabel, collectionView].forEach { view.addSubview($0) }
    }
    
    func configLayout() {
        print(#function)
        resultCntLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().inset(12)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(resultCntLabel.snp.bottom).offset(4)
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

class ShoppingListCollectionViewCell: BaseCollectionViewCell {
    
    static let id = "ShoppingListCollectionViewCell"
    
    private let imageView = UIImageView()
    private let mallNameLabel = UILabel()
    private let titleLabel = UILabel()
    private let lpriceLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configCell()
        print(#function)
    }
//    
//    init() {
//        super.init(frame: .zero)
//    }
//    
    private func configCell() {
        [imageView, mallNameLabel, titleLabel, lpriceLabel].forEach { contentView.addSubview($0) }
        
        imageView.do {
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 24
        }
        
        mallNameLabel.do {
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .gray
        }
        
        titleLabel.do {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .white
            $0.numberOfLines = 2
        }
        
        lpriceLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .bold)
            $0.textColor = .white
        }
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalTo(imageView.snp.height).multipliedBy(1.0 / 1.0)
        }
        mallNameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(12)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(mallNameLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalTo(mallNameLabel)
        }
        lpriceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalTo(mallNameLabel)
        }
        
    }
    
    func config(item: MerchandiseInfo) {
        if let url = URL(string: item.image) {
            imageView.kf.setImage(with: url)
        } else {
            print("Cell image load failed")
            imageView.image = UIImage(systemName: "xmark")!
        }
        mallNameLabel.text = item.mall
        titleLabel.text = item.title
        lpriceLabel.text = item.price
    }
}
