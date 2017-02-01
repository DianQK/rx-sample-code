//
//  TodoTableViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 06/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private typealias TodoSectionModel = AnimatableSectionModel<String, String>

class TodoTableViewController: UITableViewController {

    @IBOutlet private weak var addBarButtonItem: UIBarButtonItem!

    private let dataSource = RxTableViewSectionedAnimatedDataSource<TodoSectionModel>()

    private enum Action {
        case add(content: String)
        case delete(row: Int)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil

        do {
            dataSource.configureCell = { (dataSource, tableView, indexPath, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.basicCell, for: indexPath)!
                cell.textLabel?.text = element
                return cell
            }
            dataSource.canEditRowAtIndexPath = { _ in true }
        }

        do {
            let add = addBarButtonItem.rx.tap
                .flatMap(showTextField)
                .map(Action.add)

            let delete = tableView.rx.itemDeleted.map { $0.row }
                .map(Action.delete)

            let defaultTodoList = ["Todo 1", "Todo 2", "Todo 3"]

            Observable.from([add, delete])
                .merge()
                .scan(defaultTodoList) { acc, x in
                    switch x {
                    case let .add(content):
                        return [content] + acc
                    case let .delete(row):
                        var newItems = acc
                        newItems.remove(at: row)
                        return newItems
                    }
                }
                .startWith(defaultTodoList)
                .map { [TodoSectionModel(model: "", items: $0)] }
                .bindTo(tableView.rx.items(dataSource: dataSource))
                .disposed(by: rx.disposeBag)
        }

        do {
            tableView.rx.itemSelected
                .map { (at: $0, animated: true) }
                .subscribe(onNext: tableView.deselectRow)
                .disposed(by: rx.disposeBag)
        }

    }

}

func showTextField() -> Observable<String> {
    return Observable.create { observer in
        let alert = UIAlertController(title: "添加新的 Todo", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in

        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            observer.on(.completed)
        }))
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text {
                observer.on(.next(text))
            }
            observer.on(.completed)
        }))
        topViewController()?.showDetailViewController(alert, sender: nil)
        return Disposables.create {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
