//
//  SaveModifyItemBarButtonItem.swift
//  ReduxDemo
//
//  Created by DianQK on 04/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxExtensions

class SaveModifyItemBarButtonItem: ReactiveBarButtonItem {

    override func commonInit() {
        rx.tap.asObservable()
            .map { Action.item(.saveModify) }
            .dispatch()
            .addDisposableTo(disposeBag)
    }

}
