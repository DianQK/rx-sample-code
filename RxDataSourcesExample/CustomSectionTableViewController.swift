//
//  CustomSectionTableViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 03/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions
import RxDataSources
/// 5_1_3
class CustomSectionTableViewController: UITableViewController {

    let dataSource = RxTableViewSectionedReloadDataSource<TitleSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
            tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        }

        do {
            dataSource.configureCell = { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.basicCell, for: indexPath)!
                cell.textLabel?.text = item
                return cell
            }
        }

        do {
            let sections = Observable.just([
                TitleSectionModel(model: "Section 1", items: ["Item 1", "Item 2", "Item 3"]),
                TitleSectionModel(model: "Section 2", items: ["Item 1", "Item 2"]),
                TitleSectionModel(model: "Section 3", items: ["Item 1", "Item 2", "Item 3", "Item 4"]),
                ])

            sections
                .bindTo(tableView.rx.items(dataSource: dataSource))
                .disposed(by: rx.disposeBag)
        }

    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
        header.title = dataSource[section].model
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}

class HeaderView: UITableViewHeaderFooterView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21)
        return label
    }()

    var title: String? {
        get {
            return titleLabel.text
        }
        set(title) {
            titleLabel.text = title
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        do {
            self.contentView.backgroundColor = UIColor.white
        }

        do {
            self.contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.centerYAnchor
                .constraint(equalTo: self.contentView.centerYAnchor)
                .isActive = true
            titleLabel.leadingAnchor
                .constraint(equalTo: self.contentView.leadingAnchor, constant: 30)
                .isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
