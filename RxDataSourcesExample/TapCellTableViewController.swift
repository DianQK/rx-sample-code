//
//  TapCellTableViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 04/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

class TapCellTableViewController: UITableViewController {

    let dataSource = RxTableViewSectionedReloadDataSource<TitleSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil

        do {
            tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
            tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        }

        do {
            dataSource.configureCell = { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
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

        do {
//            tableView.rx.modelSelected(String.self)
//                .subscribe(onNext: { [unowned self] value in
//                    let alert = UIAlertController(title: "你点击了", message: value, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
//                    self.showDetailViewController(alert, sender: nil)
//                    })
//                .disposed(by: rx.disposeBag)

//            tableView.rx.itemSelected
//                .subscribe(onNext: { [unowned self] indexPath in
//                    self.tableView.deselectRow(at: indexPath, animated: true)
//                })
//                .disposed(by: rx.disposeBag)

//            tableView.rx.itemSelected
//                .map { (at: $0, animated: true) }
//                .subscribe(onNext: tableView.deselectRow)
//                .disposed(by: rx.disposeBag)

//            tableView.rx.itemSelected
//                .subscribe(onNext: { [unowned self] indexPath in
//                    let message = self.dataSource[indexPath]
//                    let title = "你点击了"
//                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
//                        self.tableView.deselectRow(at: indexPath, animated: true)
//                    }))
//                    self.showDetailViewController(alert, sender: nil)
//                })
//                .disposed(by: rx.disposeBag)

            tableView.rx.itemSelected
                .flatMap { [unowned self] indexPath -> Observable<IndexPath> in
                    let message = self.dataSource[indexPath]
                    let title = "你点击了"
                    return showEnsureAlert(title: title, message: message)
                        .map { indexPath }
                }
                .map { (at: $0, animated: true) }
                .subscribe(onNext: tableView.deselectRow)
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

func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
	   if let nav = base as? UINavigationController {
	       return topViewController(nav.visibleViewController)
	   }
	   if let tab = base as? UITabBarController {
	       if let selected = tab.selectedViewController {
	           return topViewController(selected)
	       }
	   }
	   if let presented = base?.presentedViewController {
	       return topViewController(presented)
	   }
	   return base
}

func showEnsureAlert(title: String?, message: String?) -> Observable<Void> {
    return Observable.create { observer in
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
