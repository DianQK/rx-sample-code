//
//  PHImageManager+Rx.swift
//  UploadImageDemo
//
//  Created by DianQK on 05/01/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

extension Reactive where Base: PHImageManager {

    public func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) -> Observable<(UIImage, [AnyHashable: Any]?)> {

        return Observable.create({ [weak manager = self.base] (observer) -> Disposable in
            guard let manager = manager else {
                observer.onCompleted()
                return Disposables.create()
            }

            // TODO: 多次调用
            let requestID = manager
                .requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        observer.onNext((image, info))
                        observer.onCompleted()
                    }
            })

            return Disposables.create {
                manager.cancelImageRequest(requestID)
            }

        })

    }

    public func requestImageData(for asset: PHAsset, options: PHImageRequestOptions?) -> Observable<(Data, String?, UIImageOrientation, [AnyHashable : Any]?)> {

        return Observable.create({ [weak manager = self.base] (observer) -> Disposable in
            guard let manager = manager else {
                observer.onCompleted()
                return Disposables.create()
            }

            let requestID = manager
                .requestImageData(for: asset, options: options, resultHandler: { (data, string, imageOrientation, info) in
                    if let error = info?[PHImageErrorKey] as? NSError {
                        observer.onError(error)
                    } else if let data = data {
                        observer.onNext((data, string, imageOrientation, info))
                        observer.onCompleted()
                    }
                })

            return Disposables.create {
                manager.cancelImageRequest(requestID)
            }
            
        })

    }
    
}
