//
//  Cell+Rx.swift
//  Expandable
//
//  Created by DianQK on 8/17/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITableViewCell {
    public var prepareForReuse: Observable<Void> {
        return Observable.of((base as UITableViewCell).rx.sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in }, (base as UITableViewCell).rx.deallocated).merge()
    }
    
    public var prepareForReuseBag: DisposeBag {
        return base._rx_prepareForReuseBag
    }
}

extension UITableViewCell {
    
    private struct AssociatedKeys {
        static var _disposeBag: Void = ()
    }
    
    fileprivate var _rx_prepareForReuse: Observable<Void> {
        return Observable.of(self.rx.sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in () }, self.rx.deallocated).merge()
    }

    fileprivate var _rx_prepareForReuseBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()

        if let bag = objc_getAssociatedObject(self, &AssociatedKeys._disposeBag) as? DisposeBag {
            return bag
        }

        let bag = DisposeBag()
        objc_setAssociatedObject(self, &AssociatedKeys._disposeBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

        _ = self.rx.sentMessage(#selector(UITableViewCell.prepareForReuse))
            .subscribe(onNext: { [weak self] _ in
            let newBag = DisposeBag()
            objc_setAssociatedObject(self, &AssociatedKeys._disposeBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        })

        return bag
    }
}

