//
//  MultiSelectTableViewController.swift
//  SelectCell
//
//  Created by DianQK on 19/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxDataSources
import RxExtensions

class MultiSelectTableViewController: UITableViewController {

    @IBOutlet private weak var doneBarButtonItem: UIBarButtonItem!

    private let dataSource = RxTableViewSectionedReloadDataSource<UserSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        skinTableViewDataSource(dataSource)

        do {
            tableView.rx.modelSelected(User.self)
                .subscribe(onNext: { user in
                    user.isSelected.value = !user.isSelected.value
                })
                .addDisposableTo(rx.disposeBag)

            tableView.rx.enableAutoDeselect().addDisposableTo(rx.disposeBag)
        }

        do {
            let users = getUsers().shareReplay(1)

            users
                .map(convertUsersToSections)
                .bindTo(tableView.rx.items(dataSource: dataSource))
                .addDisposableTo(rx.disposeBag)

            doneBarButtonItem.rx.tap.withLatestFrom(users)
                .map(combineSelectedUsersInfo)
                .flatMap { message in
                    return showAlert(title: "您选择了", message: message)
                }
                .subscribe(onNext: pop)
                .addDisposableTo(rx.disposeBag)

        }
    }

}
