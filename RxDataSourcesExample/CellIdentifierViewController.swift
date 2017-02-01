//
//  CellIdentifierViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 03/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions
/// 5_1_1
class CellIdentifierViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let items = Observable.just([
            "First Item",
            "Second Item",
            "Third Item"
            ])

        items
            .bindTo(tableView.rx.items(cellIdentifier: "BasicCell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element) @ row \(row)"
            }
            .disposed(by: rx.disposeBag)
    }

}
