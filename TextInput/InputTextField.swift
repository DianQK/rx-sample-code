//
//  InputTextField.swift
//  TextInputDemo
//
//  Created by DianQK on 30/01/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit

class InputTextField: UITextField {

    override var canBecomeFirstResponder: Bool {
        return _canBecomeFirstResponder && super.canBecomeFirstResponder
    }

    var _canBecomeFirstResponder: Bool = true

}
