//
//  CollectionBarButtonItem.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions

class CollectionBarButtonItem: ReactiveBarButtonItem {

    override func commonInit() {
        _state.collection
            .isEditing.asObservable()
            .map { $0 ? "Done" : "Edit" }
            .bindTo(self.rx.title)
            .addDisposableTo(disposeBag)

        self.rx.tap.asObservable()
            .map { Action.collection(.change) }
            .dispatch()
            .addDisposableTo(disposeBag)
    }

}
