//
//  DatePickerCell.swift
//  Expandable
//
//  Created by DianQK on 8/17/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DatePickerCell: UITableViewCell {

    @IBOutlet fileprivate weak var datePicker: UIDatePicker!

}

extension Reactive where Base: DatePickerCell {

    var date: ControlProperty<Date> {
        return base.datePicker.rx.date
    }

}
