//
//  ShoppingListViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 1/15/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then


final class ShoppingListViewController: BaseViewController {
    
    private let resultCntLabel = UILabel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private let filterStack = UIStackView()
    private let accuracyFilter = UIButton()
    private let dateFilter = UIButton()
    private let hPriceFilter = UIButton()
    private let lPriceFilter = UIButton()
    
    let viewModel = ShoppingListViewModel()
    
    override func bind() {
        let input = ShoppingListViewModel.Input(
            simFilter: accuracyFilter.rx.tap,
            dateFilter: dateFilter.rx.tap,
            dscFilter: hPriceFilter.rx.tap,
            ascFilter: lPriceFilter.rx.tap,
            prefetchIndex: collectionView.rx.prefetchItems,
            itemSelect: collectionView.rx.modelSelected(MerchandiseInfo.self)
        )
        let output = viewModel.transform(input: input)
        
        output.navTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.searchResult
            .drive(collectionView.rx.items(cellIdentifier: ShoppingListCollectionViewCell.id, cellType: ShoppingListCollectionViewCell.self))  { row, element, cell in
                cell.config(item: element)
                cell.clipsToBounds = true
                cell.layer.cornerRadius = 12
            }
            .disposed(by: disposeBag)
        
        output.totalNumber
            .compactMap { $0 }
            .map { "\($0) 개의 검색 결과" }
            .drive(resultCntLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.errorNoti
            .drive(with: self) { owner, message in
                AlertManager.shared.showSimpleAlert(title: "검색 실패", message: message) { _ in
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        [
            accuracyFilter.rx.tap,
            dateFilter.rx.tap,
            hPriceFilter.rx.tap,
            lPriceFilter.rx.tap
        ]
            .forEach { tap in
                tap
                    .bind(with: self, onNext: { owner, _ in
                        owner.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    })
                    .disposed(by: disposeBag)
            }
        
        Observable
            .zip (
                collectionView.rx.modelSelected(MerchandiseInfo.self),
                collectionView.rx.itemSelected
            )
            .bind(with: self) { owner, value in
                let vc = DetailWebViewController()
                vc.viewModel = DetailWebViewModel(item: value.0)
                vc.viewModel.completion = {
                    owner.collectionView.reloadItems(at: [value.1])
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configLayout() {
        [resultCntLabel, filterStack, collectionView].forEach { view.addSubview($0) }
        [accuracyFilter, dateFilter, hPriceFilter, lPriceFilter].forEach { filterStack.addArrangedSubview($0) }
        
        resultCntLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(viewModel.spacing)
            $0.leading.equalToSuperview().inset(viewModel.spacing)
        }
        filterStack.snp.makeConstraints {
            $0.top.equalTo(resultCntLabel.snp.bottom).offset(viewModel.spacing)
            $0.horizontalEdges.equalToSuperview().inset(viewModel.spacing)
            $0.height.equalTo(32)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(filterStack.snp.bottom).offset(viewModel.spacing)
            $0.horizontalEdges.equalToSuperview().inset(viewModel.spacing)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func configView() {
        resultCntLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .heavy)
            $0.textColor = .systemGreen
        }
        
        filterStack.do {
            $0.axis = .horizontal
            $0.spacing = viewModel.spacing
            $0.distribution = .fillProportionally
        }
        
        [
            (accuracyFilter, "정확도"),
            (dateFilter, "날짜순"),
            (hPriceFilter, "가격높은순"),
            (lPriceFilter, "가격낮은순")
        ]
            .forEach { $0.configuration = .sortButtonStyle(title: $1) }
        
        collectionView.do {
            $0.backgroundColor = .clear
            $0.register(ShoppingListCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingListCollectionViewCell.id)
        }
    }
    
    override func configNavigation() {
        navigationItem.backButtonTitle = ""
    }
}

// MARK: Extension
extension ShoppingListViewController {
   private func layout() -> UICollectionViewFlowLayout {
       let layout = UICollectionViewFlowLayout()
       layout.itemSize = CGSize(
        width: Int(UIScreen.main.bounds.width - viewModel.spacing * 3) / 2,
        height: Int(UIScreen.main.bounds.height) / 3)
       layout.scrollDirection = .vertical
       layout.minimumLineSpacing = viewModel.spacing
       layout.minimumInteritemSpacing = viewModel.spacing
       return layout
   }
}
