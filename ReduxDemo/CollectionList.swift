//
//  CollectionList.swift
//  ReduxDemo
//
//  Created by DianQK on 04/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxExtensions

class CollectionList: UIViewController {

    @IBOutlet private weak var collectionView: CollectionView!
    @IBOutlet private weak var collectionEditBarButtonItem: ReactiveBarButtonItem! {
        didSet {
            _state.collection
                .isEditing.asObservable()
                .map { $0 ? "Done" : "Edit" }
                .bindTo(collectionEditBarButtonItem.rx.title)
                .addDisposableTo(collectionEditBarButtonItem.disposeBag)

            collectionEditBarButtonItem.rx.tap.asObservable()
                .replace(with: Action.collection(.change))
                .dispatch()
                .addDisposableTo(collectionEditBarButtonItem.disposeBag)
        }
    }

}
