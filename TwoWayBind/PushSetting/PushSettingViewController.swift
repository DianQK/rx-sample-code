//
//  PushSettingViewController.swift
//  RxDealCell
//
//  Created by DianQK on 8/8/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

typealias PushSettingSectionModel = AnimatableSectionModel<String, PushItemModel>

class PushSettingViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(SelectTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SelectTableViewHeaderFooterView.reuseIdentifier)
            tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        }
    }

    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<PushSettingSectionModel> { _, tableView, indexPath, value in
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectTableViewCell, for: indexPath)!
        cell.name = value.pushType.name
        (cell.rx.select <-> value.select).disposed(by: cell.rx.prepareForReuseBag)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.just(pushSettingData)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

    }
}

extension PushSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SelectTableViewHeaderFooterView.reuseIdentifier) as! SelectTableViewHeaderFooterView
        header.name = dataSource[section].model
        let selectItems = dataSource[section].items.map { $0.select }
        Observable.combineLatest(selectItems.map { $0.asObservable() }) { $0.contains(true) }
            .bindTo(header.rx.isSelected)
            .disposed(by: header.rx.prepareForReuseBag)

        header.rx
            .isSelected
            .subscribe(onNext: { isSelectedAll in
                selectItems.forEach { $0.value = isSelectedAll }
            })
            .disposed(by: header.rx.prepareForReuseBag)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
