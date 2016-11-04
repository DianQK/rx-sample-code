//
//  EditItem.swift
//  ReduxDemo
//
//  Created by DianQK on 04/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions

class EditItem: UIViewController {

    @IBOutlet private weak var cancelBarButtonItem: ReactiveBarButtonItem! {
        didSet {
            cancelBarButtonItem.rx.tap
                .replace(with: Action.item(ItemAction.cancelModify))
                .dispatch()
                .addDisposableTo(cancelBarButtonItem.disposeBag)
        }
    }

    @IBOutlet private weak var saveBarButtonItem: ReactiveBarButtonItem! {
        didSet {
            saveBarButtonItem.rx.tap.asObservable()
                .replace(with: Action.item(.saveModify))
                .dispatch()
                .addDisposableTo(saveBarButtonItem.disposeBag)
        }
    }

    @IBOutlet private weak var editImageView: ReactiveImageView! {
        didSet {
            _state.item.modifyItem.asObservable()
                .flatMap { item in
                    return item?.logo.asObservable() ?? Observable.empty()
                }
                .take(1)
                .bindTo(editImageView.rx.image)
                .addDisposableTo(editImageView.disposeBag)

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
            editImageView.isUserInteractionEnabled = true
            editImageView.addGestureRecognizer(tap)

            modifyImage
                .bindTo(editImageView.rx.image)
                .addDisposableTo(editImageView.disposeBag)

            modifyImage
                .map { Action.item(ItemAction.modifyImage($0)) }
                .dispatch()
                .addDisposableTo(editImageView.disposeBag)
        }
    }

    @IBOutlet private weak var editTitleField: ReactiveTextField! {
        didSet {
            editTitleField.text = _state.item.modifyItem.value?.title.value
            editTitleField.rx.text
                .map { Action.item(.modifyTitle($0!)) }
                .dispatch()
                .addDisposableTo(editTitleField.disposeBag)
        }
    }

}
