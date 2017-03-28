//
//  CartViewController.swift
//  RxDealCell
//
//  Created by DianQK on 8/4/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

struct ProductInfo {
    let id: Int
    let name: String
    let unitPrice: Int
    let count: Variable<Int>
}

extension ProductInfo: Hashable, Equatable, IdentifiableType {
    var hashValue: Int {
        return id.hashValue
    }
    var identity: Int {
        return id
    }

    static func ==(lhs: ProductInfo, rhs: ProductInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

typealias ProductSectionModel = AnimatableSectionModel<String, ProductInfo>



class CartViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    @IBOutlet private weak var purchaseButton: UIButton!

    private let dataSource = RxTableViewSectionedReloadDataSource<ProductSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let products = [1, 2, 3, 4]
            .map { ProductInfo(id: 1000 + $0, name: "Product\($0)", unitPrice: $0 * 100, count: Variable(1)) }

        let sectionInfo = Observable.just([ProductSectionModel(model: "", items: products)])
            .shareReplay(1)

        dataSource.configureCell = { _, tableView, indexPath, product in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productTableViewCell, for: indexPath)!
            cell.name = product.name
            cell.setUnitPrice(product.unitPrice)
            (cell.rx_count <-> product.count).disposed(by: cell.rx.prepareForReuseBag)
            return cell
        }

        sectionInfo
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        let totalPrice = sectionInfo
            .map { $0.flatMap { $0.items } }
            .flatMap { $0.reduce(.just(0)) { acc, x in
            Observable.combineLatest(acc, x.count.asObservable().map { x.unitPrice * $0 }, resultSelector: +)
            }
        }
            .shareReplay(1)

        totalPrice
            .map { "总价：\($0) 元" }
            .bindTo(totalPriceLabel.rx.text)
            .disposed(by: rx.disposeBag)

        totalPrice
            .map { $0 != 0 }
            .bindTo(purchaseButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        tableView.rx.enableAutoDeselect().disposed(by: rx.disposeBag)

    }

}
