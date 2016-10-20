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

    var isSelected: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: selectSwitch) { selectSwitch, isSelected in
            selectSwitch.setOn(isSelected, animated: true)
        }
            .asObserver()
    }

    var selectSwitchChangedAction: ((Bool) -> Void)?

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private lazy var selectSwitch: UISwitch = {
        let selectSwitch = UISwitch()
        selectSwitch.addTarget(self, action: #selector(SelectTableViewHeaderFooterView.selectSwitchChanged), for: .valueChanged)
        return selectSwitch
    }()

    private(set) var reusableDisposeBag = DisposeBag()

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

    override func prepareForReuse() {
        super.prepareForReuse()
        reusableDisposeBag = DisposeBag()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private dynamic func selectSwitchChanged() {
        selectSwitchChangedAction?(selectSwitch.isOn)
    }
}
