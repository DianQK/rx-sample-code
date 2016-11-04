//
//  ModifyItemImageView.swift
//  ReduxDemo
//
//  Created by DianQK on 04/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxExtensions

class ModifyItemImageView: ReactiveImageView {

    override func commonInit() {
        _state.item.modifyItem.asObservable()
            .flatMap { item in
                return item?.logo.asObservable() ?? Observable.empty()
            }
            .take(1)
            .bindTo(rx.image)
            .addDisposableTo(disposeBag)

        let tap = UITapGestureRecognizer()
        let modifyImage = tap.rx.event.map { _ in }
            .flatMapLatest {
                UIImagePickerController.rx.createWithParent(topViewController()!) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
                    }
                    .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                    .take(1) // catch error
            }
            .map { info in
                return info[UIImagePickerControllerEditedImage] as! UIImage
            }
            .shareReplay(1)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)

        modifyImage
            .bindTo(self.rx.image)
            .addDisposableTo(disposeBag)

        modifyImage
            .map { Action.item(ItemAction.modifyImage($0)) }
            .dispatch()
            .addDisposableTo(disposeBag)

    }

}
