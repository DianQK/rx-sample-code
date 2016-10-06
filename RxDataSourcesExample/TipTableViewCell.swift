//
//  TipTableViewCell.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 03/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TipTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var switchView: UISwitch!

    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    var isOn: Bool {
        get {
            return switchView.isOn
        }
        set(isOn) {
            switchView.isOn = isOn
        }
    }

    var title: String? {
        get {
            return titleLabel.text
        }
        set(title) {
            titleLabel.text = title
        }
    }
}

extension Reactive where Base: TipTableViewCell {
    var isOn: ControlProperty<Bool> {
        return base.switchView.rx.value
    }
}
