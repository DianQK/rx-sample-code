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

typealias PushSettingSectionModel = AnimatableSectionModel<PushSectionModel, PushItemModel>

class PushSettingViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(SelectTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SelectTableViewHeaderFooterView.reuseIdentifier)
            tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        }
    }
    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<PushSettingSectionModel>()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        func combineItems(items: [PushItemModel]) -> Observable<Bool> {
            guard let first = items.first else {
                return Observable.empty()
            }
            return items.dropFirst().reduce(first.isSelected.asObservable()) { acc, x in
                Observable.combineLatest(acc, x.isSelected.asObservable()) { $0 || $1 }
            }
        }

        for section in pushSettingData {
            combineItems(items: section.items).bindTo(section.model.isSelectedAll).addDisposableTo(disposeBag)
        }

        Observable.just(pushSettingData)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        dataSource.configureCell = { _, tableView, indexPath, value in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectTableViewCell, for: indexPath)!
            cell.name = value.pushType.name
            (cell.rx.isSelected <-> value.isSelected).addDisposableTo(cell.rx.prepareForReuseBag)
            return cell
        }
    }
}

extension PushSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SelectTableViewHeaderFooterView.reuseIdentifier) as! SelectTableViewHeaderFooterView
        let sectionModel = dataSource[section].model
        header.name = sectionModel.category
        sectionModel.isSelectedAll.asObservable().bindTo(header.isSelected).addDisposableTo(header.reusableDisposeBag)
        header.selectSwitchChangedAction = { [unowned self] isSelected in
            self.dataSource[section].items.forEach {
                $0.isSelected.value = isSelected
            }
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
