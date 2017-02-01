//
//  SelectTableViewHeaderFooterView.swift
//  RxDealCell
//
//  Created by DianQK on 8/8/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SelectTableViewHeaderFooterView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "SelectTableViewHeaderFooterView"

    var name: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }

    fileprivate lazy var selectSwitch = UISwitch()
    private lazy var nameLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView).offset(30)
            make.centerY.equalTo(self.contentView)
        }

        contentView.addSubview(selectSwitch)
        selectSwitch.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.contentView).offset(-30)
            make.centerY.equalTo(self.contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension Reactive where Base: UISwitch {
    public var isOn: ControlProperty<Bool> {
        let source = self.controlEvent(.valueChanged)
            .map { [unowned uiSwitch = self.base] in uiSwitch.isOn }
        let sink = UIBindingObserver<UISwitch, Bool>(UIElement: self.base) { uiSwitch, isOn in
            guard uiSwitch.isOn != isOn else { return }
            uiSwitch.setOn(isOn, animated: true)
        }
        return ControlProperty(values: source, valueSink: sink)
    }
}

extension Reactive where Base: SelectTableViewHeaderFooterView {
    var isSelected: ControlProperty<Bool> {
        return base.selectSwitch.rx.isOn(animated: true)
    }
}
