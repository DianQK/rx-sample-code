//
//  ChangeSwitchTableViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 06/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

private struct Option {
    let title: String
    let isOn: Variable<Bool>
    init(title: String, isOn: Bool) {
        self.title = title
        self.isOn = Variable(isOn)
    }
}

/// 5_3_2
class ChangeSwitchTableViewController: UITableViewController {

    @IBOutlet private weak var completedBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil

        let items = [
            Option(title: "选项一", isOn: true),
            Option(title: "选项二", isOn: false),
            Option(title: "选项三", isOn: true)
            ]

        do {
            completedBarButtonItem.rx.tap
                .map { items }
                .map { $0.map { $0.title + ": \($0.isOn.value)." }.joined(separator: "\n") }
                .flatMap { displayText in
                    showAlert(title: "当前结果", message: displayText)
                }
                .subscribe(onNext: { [unowned self] in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                .disposed(by: rx.disposeBag)
        }

        do {
            Observable.just(items)
                .bindTo(tableView.rx.items(cellIdentifier: "TipTableViewCell", cellType: TipTableViewCell.self)) { (row, element, cell) in
                    cell.title = element.title
                    (cell.rx.isOn <-> element.isOn).disposed(by: cell.disposeBag)
                }
                .disposed(by: rx.disposeBag)
        }

    }
    
}

func showAlert(title: String?, message: String?) -> Observable<Void> {
    return Observable.create { observer in
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            observer.on(.completed)
        }))
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
            observer.on(.next(()))
            observer.on(.completed)
        }))
        topViewController()?.showDetailViewController(alert, sender: nil)
        return Disposables.create {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
