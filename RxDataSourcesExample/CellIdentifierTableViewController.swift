//
//  CellIdentifierTableViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 03/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions

private struct Option {
    let title: String
    let isOn: Bool
    init(title: String, isOn: Bool) {
        self.title = title
        self.isOn = isOn
    }
}

/// 5_1_2
class CellIdentifierTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil

        let items = Observable.just([
            Option(title: "选项一", isOn: true),
            Option(title: "选项二", isOn: false),
            Option(title: "选项三", isOn: true),
            ])

        items
            .bindTo(tableView.rx.items(cellIdentifier: "TipTableViewCell", cellType: TipTableViewCell.self)) { (row, element, cell) in
                cell.title = element.title
                cell.isOn = element.isOn
            }
            .disposed(by: rx.disposeBag)

    }

}
