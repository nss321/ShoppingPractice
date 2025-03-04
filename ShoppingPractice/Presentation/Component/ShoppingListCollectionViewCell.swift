//
//  ShoppingListCollectionViewCell 2.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit

import Kingfisher
import RxSwift
import SnapKit
import Then

final class ShoppingListCollectionViewCell: BaseCollectionViewCell {
    
    static let id = "ShoppingListCollectionViewCell"
    
    private let imageView = UIImageView()
    private let mallNameLabel = UILabel()
    private let titleLabel = UILabel()
    private let lpriceLabel = UILabel()
    private let likeButton = CustomLikeButton()
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        mallNameLabel.text = nil
        titleLabel.text = nil
        lpriceLabel.text = nil
        likeButton.viewModel = nil
    }
    
    deinit {
//        print(self, "deinit")
    }

    override func configCell() {
        [imageView, mallNameLabel, titleLabel, lpriceLabel, likeButton].forEach { contentView.addSubview($0) }
        
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
        likeButton.snp.makeConstraints {
            $0.size.equalTo(imageView.snp.width).dividedBy(5)
            $0.trailing.equalTo(imageView.snp.trailing).inset(12)
            $0.bottom.equalTo(imageView.snp.bottom).inset(12)
        }
        
        imageView.do {
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
        }
        
        mallNameLabel.do {
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .secondaryLabel
        }
        
        titleLabel.do {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .label
            $0.numberOfLines = 2
        }
        
        lpriceLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .bold)
            $0.textColor = .label
        }
    }
    
    func config(item: MerchandiseInfo) {
        let formatter = NumberFormatter().then { $0.numberStyle = .decimal }
        let price = Int(item.price) ?? 0
        if let url = URL(string: item.image) {
            imageView.kf.setImage(with: url)
        } else {
            print("Cell image load failed")
            imageView.image = UIImage(systemName: "xmark")!
        }
        mallNameLabel.text = item.mall
        titleLabel.text = item.title.escapingHTML
        lpriceLabel.text = "\(formatter.string(for: price) ?? "0")원"
        likeButton.bind(viewModel: CustomLikeButtonViewModel(item: item))
    }
}
