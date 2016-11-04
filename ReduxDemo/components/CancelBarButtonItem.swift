//
//  CancelBarButtonItem.swift
//  ReduxDemo
//
//  Created by DianQK on 04/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxExtensions

class CancelBarButtonItem: ReactiveBarButtonItem {
    override func commonInit() {
        rx.tap
            .map { Action.item(ItemAction.cancelModify) }
            .dispatch()
            .addDisposableTo(disposeBag)
    }
}
