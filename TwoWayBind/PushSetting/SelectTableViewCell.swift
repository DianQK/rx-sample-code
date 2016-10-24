//
//  SelectTableViewCell.swift
//  RxDealCell
//
//  Created by DianQK on 8/8/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SelectTableViewCell: UITableViewCell {

    var name: String? {
        get {
            return nameLabel?.text
        }
        set {
            nameLabel.text = newValue
        }
    }

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var selectButton: UIButton! {
        didSet {
            selectButton.addTarget(self, action: #selector(SelectTableViewCell.selectButtonTap), for: .touchUpInside)
        }
    }

    fileprivate var _isSelectedChanged: ((Bool) -> Void)?

    private dynamic func selectButtonTap() {
        selectButton.isSelected = !selectButton.isSelected
        _isSelectedChanged?(selectButton.isSelected)
    }

}

extension Reactive where Base: SelectTableViewCell {
    var isSelected: ControlProperty<Bool> {
        let source = Observable<Bool>.create { [weak cell = self.base](observer) in
            cell?._isSelectedChanged = observer.onNext
            return Disposables.create()
        }
        let sink = base.selectButton.rx.isSelected
        return ControlProperty(values: source, valueSink: sink)
    }
}
