//
//  TextFieldCell.swift
//  Expandable
//
//  Created by DianQK on 8/17/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextFieldCell: UITableViewCell {

    @IBOutlet fileprivate weak var textField: UITextField!

    var placeholder: String? {
        get {
            return textField?.placeholder
        }
        set {
            textField?.placeholder = newValue
        }
    }

}

extension Reactive where Base: TextFieldCell {
    var text: ControlProperty<String> {
        return base.textField.rx.textInput.text
    }
}
