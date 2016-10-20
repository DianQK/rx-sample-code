//
//  UserTableViewCell.swift
//  SelectCell
//
//  Created by DianQK on 19/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import RxSwift
import RxCocoa
import RxExtensions

class UserTableViewCell: ReactiveTableViewCell { }

extension Reactive where Base: UserTableViewCell {
    var isMarked: UIBindingObserver<UserTableViewCell, Bool> {
        return UIBindingObserver(UIElement: self.base, binding: { (cell, isMarked) in
            cell.accessoryType = isMarked ? .checkmark : .none
        })
    }
}
