//
//  SectionTableViewController.swift
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
typealias TitleSectionModel = SectionModel<String, String>

class SectionTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil

        let dataSource = RxTableViewSectionedReloadDataSource<TitleSectionModel>()

        dataSource.configureCell = { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.basicCell, for: indexPath)!
            cell.textLabel?.text = item
            return cell
        }

        dataSource.titleForHeaderInSection = { dataSource, section in
            return dataSource[section].model
        }

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
