//
//  QBImagePickerController+Rx.swift
//  UploadImageDemo
//
//  Created by DianQK on 05/01/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import QBImagePicker
import RxSwift
import RxCocoa

extension Reactive where Base: QBImagePickerController {

    public var delegate: DelegateProxy {
        return RxQBImagePickerControllerDelegateProxy.proxyForObject(base)
    }

    public var didFinishPickingAssets: Observable<[PHAsset]> {
        return delegate.methodInvoked(#selector(QBImagePickerControllerDelegate.qb_imagePickerController(_:didFinishPickingAssets:)))
            .map { (a) -> [PHAsset] in
                return a[1] as! [PHAsset]
            }
            .do(onNext: { [unowned base = self.base] _ in
                base.dismiss(animated: true, completion: nil)
            })
            .asObservable()
    }

    public var didCancel: Observable<()> {
        return delegate.methodInvoked(#selector(QBImagePickerControllerDelegate.qb_imagePickerControllerDidCancel(_:)))
            .map { _ in
                return ()
            }
            .do(onNext: { [unowned base = self.base] _ in
                base.dismiss(animated: true, completion: nil)
            })
            .asObservable()
    }

}
