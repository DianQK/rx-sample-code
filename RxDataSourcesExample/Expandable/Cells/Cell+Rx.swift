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

private var _prepareForReuseBag: Void = ()

extension UITableViewCell {
    fileprivate var rx_prepareForReuse: Observable<Void> {
        return Observable.of(self.rx.sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in () }, self.rx.deallocated).merge()
    }

    fileprivate var rx_prepareForReuseBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()

        if let bag = objc_getAssociatedObject(self, &_prepareForReuseBag) as? DisposeBag {
            return bag
        }

        let bag = DisposeBag()
        objc_setAssociatedObject(self, &_prepareForReuseBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

        _ = self.rx.sentMessage(#selector(UITableViewCell.prepareForReuse))
            .subscribe(onNext: { [weak self] _ in
            let newBag = DisposeBag()
            objc_setAssociatedObject(self, &_prepareForReuseBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        })

        return bag
    }
}

extension Reactive where Base: UITableViewCell {
    var prepareForReuse: Observable<Void> {
        return Observable.of((base as UITableViewCell).rx.sentMessage(#selector(UITableViewCell.prepareForReuse)).map { _ in }, (base as UITableViewCell).rx.deallocated).merge()
    }

    var prepareForReuseBag: DisposeBag {
        return base.rx_prepareForReuseBag
    }
}
