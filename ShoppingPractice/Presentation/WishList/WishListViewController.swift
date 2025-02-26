//
//  WishList.swift
//  ShoppingPractice
//
//  Created by BAE on 2/26/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit


final class WishListViewController: BaseViewController {
    
    enum Section: CaseIterable {
        case new
        case main
        case sub
    }
    
    private let searchBar = UISearchBar()

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, DiffableModel>!
    
    private var filledList = DiffableModel.mockData() {
        didSet {
            updateSnapshot()
        }
    }
    
    private var basicList = DiffableModel.mockData2() {
        didSet {
            updateSnapshot()
        }
    }
    
    private var newList = [DiffableModel]() {
        didSet {
            updateSnapshot()
        }
    }
    
    override func configLayout() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    override func configView() {
        searchBar.placeholder = "이곳에 추가하세요."
        searchBar.barTintColor = .systemGroupedBackground
        searchBar.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        searchBar.layer.borderWidth = 1
        searchBar.delegate = self

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        
        configDataSource()
        updateSnapshot()
    }
    
    override func configNavigation() {
        navigationItem.title = "Wish Wish"
    }
}

private extension WishListViewController {
    func layout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
    
    func configDataSource() {
        var registration: UICollectionView.CellRegistration<UICollectionViewListCell, DiffableModel>
        registration = UICollectionView.CellRegistration(handler: { cell, indexPath, itemIdentifier in
            
            var content = UIListContentConfiguration.valueCell()
            cell.contentConfiguration = content
            content.text = "\(itemIdentifier.content)"
            content.textProperties.color = .label
            content.textProperties.font = .systemFont(ofSize: 16)
            content.secondaryText = "생성일 " + itemIdentifier.date
            content.secondaryTextProperties.font = .systemFont(ofSize: 12)
            content.secondaryTextProperties.color = .secondaryLabel
            content.image = UIImage(systemName: itemIdentifier.image)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            
            /*
             - text와 secondaryText 영역이 겹치면 secondaryText가 아래로 이동
             */
            
            
            var backgroundConfig: UIBackgroundConfiguration

            if #available(iOS 18, *) {
                backgroundConfig = UIBackgroundConfiguration.listCell()
            } else {
                backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
            }

            backgroundConfig.cornerRadius = 12
            backgroundConfig.strokeWidth = 2
            cell.backgroundConfiguration = backgroundConfig
            
            cell.contentConfiguration = content
        })
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DiffableModel>()
        snapshot.appendSections(newList.isEmpty ? [Section.main, Section.sub] : Section.allCases)
        snapshot.appendItems(filledList, toSection: .main)
        snapshot.appendItems(basicList, toSection: .sub)
        if !newList.isEmpty { snapshot.appendItems(newList, toSection: .new) }
        
        dataSource.apply(snapshot)
    }
    
    func deleteItem(item: DiffableModel, list: inout [DiffableModel]) {
        if let index = list.firstIndex(of: item) {
            list.remove(at: index)
        } else {
            AlertManager.shared.showSimpleAlert(title: "알 수 없는 오류", message: "항목을 찾을 수 없습니다.")
            print(#function, "\(list)에 \(item)이 존재하지 않습니다.")
        }
    }
    
    func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath,
                let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        // 왜 3번, 1번 총 4번 호출되는걸까
        print(item)
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            if let index = self?.filledList.firstIndex(of: item) {
                self?.filledList.remove(at: index)
            }
            completion(false)
        }
    
        deleteAction.image = UIImage(systemName: "trash.fill")
    
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

extension WishListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text!
        let newElement = DiffableModel.init(image: "moonphase.new.moon", content: text, date: .now)
        newList.insert(newElement, at: 0)
        if newList.count > 1 { newList[1].image = "moonphase.new.moon.inverse" }

        print(#function, text)
    }
}

extension WishListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        if let data = dataSource.itemIdentifier(for: indexPath) {
            AlertManager.shared.showDestructiveAlert(title: "삭제", message: "\(data.content)를 삭제하시겠습니까?") { [weak self] _ in
                guard let self else {
                    print(#function, "failed to unwrapping self")
                    return
                }
                switch indexPath.section {
                case 0:
                    self.deleteItem(item: data, list: &self.newList)
                case 1:
                    self.deleteItem(item: data, list: &self.filledList)
                case 2:
                    self.deleteItem(item: data, list: &self.basicList)
                default:
                    return
                }
            }
        }
    }
}
//
//#Preview(traits: .defaultLayout, body: {
//    WishListViewController()
//})
