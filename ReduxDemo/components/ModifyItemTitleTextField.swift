//
//  ModifyItemTitleTextField.swift
//  ReduxDemo
//
//  Created by DianQK on 04/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxExtensions

class ModifyItemTitleTextField: ReactiveTextField {

    override func commonInit() {
        self.text = _state.item.modifyItem.value?.title.value
        self.rx.text
            .map { Action.item(.modifyTitle($0!)) }
            .dispatch()
            .addDisposableTo(disposeBag)
    }

}
