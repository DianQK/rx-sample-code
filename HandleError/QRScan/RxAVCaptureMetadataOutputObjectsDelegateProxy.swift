//
//  RxAVCaptureMetadataOutputObjectsDelegateProxy.swift
//  HandleError
//
//  Created by wc on 28/12/2016.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

//    open class func requestAccess(forMediaType mediaType: String!, completionHandler handler: ((Bool) -> Swift.Void)!)

extension Reactive where Base: AVCaptureDevice {

    public static func requestAccess(forMediaType mediaType: String) -> Observable<Bool> {
        return Observable<Bool>.create { (observer) -> Disposable in
            AVCaptureDevice
                .requestAccess(forMediaType: mediaType, completionHandler: { result in
                    observer.onNext(result)
                    observer.onCompleted()
                })
            return Disposables.create()
        }
    }

}

public class RxAVCaptureMetadataOutputObjectsDelegateProxy: DelegateProxy, DelegateProxyType, AVCaptureMetadataOutputObjectsDelegate {
    
    public static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let captureMetadataOutput = object as? AVCaptureMetadataOutput
        let delegate = delegate as? AVCaptureMetadataOutputObjectsDelegate
        captureMetadataOutput?.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
    }
    
    public static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let captureMetadataOutput = object as? AVCaptureMetadataOutput
        return captureMetadataOutput?.metadataObjectsDelegate
    }
    
}


extension Reactive where Base: AVCaptureMetadataOutput {
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: DelegateProxy {
        return RxAVCaptureMetadataOutputObjectsDelegateProxy.proxyForObject(base)
    }
    
    public var didOutputMetadataObjects: Observable<(metadataObjects: [Any], connection: AVCaptureConnection)> {
        return delegate
            .methodInvoked(#selector(AVCaptureMetadataOutputObjectsDelegate.captureOutput(_:didOutputMetadataObjects:from:)))
            .map { a in
                return (metadataObjects: a[1] as! [Any], connection: a[2] as! AVCaptureConnection)
            }
            .asObservable()
    }

}
        
