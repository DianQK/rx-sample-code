//
//  ProductTableViewCell.swift
//  RxDealCell
//
//  Created by DianQK on 8/4/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ProductTableViewCell: UITableViewCell {

    var name: String? {
        get {
            return nameLabel?.text
        }
        set {
            nameLabel?.text = newValue
        }
    }

    private var _count: Int = 0 {
        didSet {
            if _count < 1 {
                fatalError()
            }
            minusButton.isEnabled = _count - 1 != 0
            countLabel.text = String(_count)
        }
    }

    private var countChanged: ((Int) -> Void)?

    var rx_count: ControlProperty<Int> {
        let source = Observable<Int>.create { [weak self](observer) in
            self?.countChanged = observer.onNext
            return Disposables.create()
        }
            .distinctUntilChanged()

        let sink = UIBindingObserver(UIElement: self) { cell, count in
            cell._count = count
        }
            .asObserver()

        return ControlProperty(values: source, valueSink: sink)
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var unitPriceLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var minusButton: UIButton! {
        didSet {
            minusButton.addTarget(self, action: #selector(ProductTableViewCell.minusButtonTap), for: .touchUpInside)
        }
    }

    @IBOutlet private weak var plusButton: UIButton! {
        didSet {
            plusButton.addTarget(self, action: #selector(ProductTableViewCell.plusButtonTap), for: .touchUpInside)
        }
    }

    func setUnitPrice(_ unitPrice: Int) {
        unitPriceLabel.text = "单价：\(unitPrice) 元"
    }

    private dynamic func minusButtonTap() {
        changeCount(-=)
    }

    private dynamic func plusButtonTap() {
        changeCount(+=)
    }

    private typealias Action = (_ lhs: inout Int, _ rhs: Int) -> Void

    private func changeCount(_ action: Action) {
        action(&_count, 1)
        countChanged?(_count)
    }

}
