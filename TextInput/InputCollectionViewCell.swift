//
//  InputCollectionViewCell.swift
//  TextInputDemo
//
//  Created by DianQK on 18/01/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InputCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textField: InputTextField!

    var isInputing: UIBindingObserver<InputCollectionViewCell, Bool> {
        return UIBindingObserver(UIElement: self, binding: { (UIElement, value) in
            UIElement.textField._canBecomeFirstResponder = value
            if value {
                _ = UIElement.becomeFirstResponder()
            } else {
                _ = UIElement.resignFirstResponder()
            }
        })
    }

    var canInput: UIBindingObserver<InputCollectionViewCell, Bool> {
        return UIBindingObserver(UIElement: self, binding: { (UIElement, value) in
            UIElement.textField._canBecomeFirstResponder = value
        })
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    } 

    override var canResignFirstResponder: Bool {
        return textField.canResignFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }

    private(set) var reuseDisposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        reuseDisposeBag = DisposeBag()
    }

}
