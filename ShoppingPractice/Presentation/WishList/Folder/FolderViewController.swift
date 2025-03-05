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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.reloadData()
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
//                content.secondaryText = "\(element.detail.count)개"
                cell.contentConfiguration = content
                
                var backgroundConfig = UIBackgroundConfiguration.listCell()
//                backgroundConfig.backgroundColor = .yellow
//                backgroundConfig.cornerRadius = 12
//                backgroundConfig.strokeColor = .systemRed
//                backgroundConfig.strokeWidth = 2
                cell.backgroundConfiguration = backgroundConfig
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Folder.self)
            .bind(with: self) { owner, folder in
                print(folder)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"), primaryAction: UIAction(handler: { _ in
                AlertManager.shared.showSimpleAlert(title: "폴더 추가", message: "준비중입니다.")
            })
        )
    }
}

//extension FolderViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return list.count
//    }
//    
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as! ListTableViewCell
//        
//        let data = list[indexPath.row]
//        cell.titleLabel.text = data.name
//        cell.subTitleLabel.text = "\(data.detail.count)개"
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let data = list[indexPath.row]
//        let vc = FolderDetailViewController()
//        vc.list = data.detail
//        vc.id = data.id
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//      
//}
