//
//  FolderViewController.swift
//  ShoppingPractice
//
//  Created by BAE on 3/5/25.
//

import UIKit

import RealmSwift
import RxCocoa
import RxSwift
import SnapKit

final class FolderViewController: BaseViewController {
    private lazy var tableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.rowHeight = 44
        view.register(UITableViewCell.self, forCellReuseIdentifier: "folder")
        return view
    }()
    
    private let viewModel = FolderViewModel()
    
    // MARK: Deinit은 잘 되는거 같은데 램 사용량이 증가한 것 같다. 렐름 사용하면 메모리를 더 많이 먹,,나?
    deinit {
        print(#function)
    }
    
    override func bind() {
        let input = FolderViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.storedFolder
            .drive(tableView.rx.items(cellIdentifier: "folder", cellType: UITableViewCell.self)) { row, element, cell in

                var content = cell.defaultContentConfiguration()
                content.text = element.name
                content.textProperties.font = .systemFont(ofSize: 16)
                content.textProperties.color = .label
                content.secondaryText = "\(element.count)개"
                content.secondaryTextProperties.font = .systemFont(ofSize: 12)
                content.secondaryTextProperties.color = .secondaryLabel
                cell.contentConfiguration = content
    
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(with: self) { owner, index in
                print(owner.viewModel.id(index: index.row))
                let vc = WishListViewController()
                vc.viewModel = WishListViewModel(
                    id: owner.viewModel.id(index: index.row),
                    list: owner.viewModel.list(index: index.row),
                    navTitle: owner.viewModel.title(index: index.row)
                )
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configNavigation() {
        navigationItem.backButtonTitle = ""
        navigationItem.title = "Wish Wish"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"), primaryAction: UIAction(handler: { _ in
                AlertManager.shared.showSimpleAlert(title: "폴더 추가", message: "준비중입니다.")
            })
        )
    }
}
