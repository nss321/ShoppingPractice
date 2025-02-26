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
            prefetchIndex: collectionView.rx.prefetchItems
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
//            $0.prefetchDataSource = self
            $0.register(ShoppingListCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingListCollectionViewCell.id)
        }
    }
    
    override func configNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left")!.withTintColor(.label, renderingMode: .alwaysOriginal),
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
        )
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

//extension ShoppingListViewController: UICollectionViewDataSourcePrefetching {
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
////        print(#function, "프리패칭 호출!!!")
//        for item in indexPaths {
//            if viewModel.currentPage - 3 == item.row {
//                // 프리페칭
//                // 마지막 검색어, 마지막 필터, 현재 페이지를 startAt으로 30개를 더 가져옴
//                // 가져온 30개를 기존 데이터 outputShoppingList에 붙임.
//                viewModel.inputPrefetching.value = ()
//            }
//        }
//    }
//}

// MARK: UIGestureReconizerDelegate
extension ShoppingListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
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
