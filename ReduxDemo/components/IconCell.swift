//
//  IconCell.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions

class IconCell: ReactiveCollectionViewCell {

    @IBOutlet private weak var iconImageView: UIImageView! {
        didSet {
            self.iconImageView.layer.cornerRadius = 8.0
            self.iconImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!

    let item = ReplaySubject<IconItem>.create(bufferSize: 1)

    override func commonInit() {
        item.flatMapLatest { $0.logo.asObservable() }.bindTo(iconImageView.rx.image).addDisposableTo(disposeBag)
        item.flatMapLatest { $0.title.asObservable() }.bindTo(titleLabel.rx.text).addDisposableTo(disposeBag)
        Observable.combineLatest(item, _state.collection
            .isEditing.asObservable()) { $0.1 }
            .bindTo(self.rx.isEditing)
            .addDisposableTo(disposeBag)

        deleteButton.rx.tap
            .withLatestFrom(item.asObservable())
            .map { Action.collection(CollectionAction.remove(item: $0)) }
            .dispatch()
            .addDisposableTo(disposeBag)
    }

    func startWiggling() {
        guard contentView.layer.animation(forKey: "wiggle") == nil else { return }
        guard contentView.layer.animation(forKey: "bounce") == nil else { return }

        let angle = 0.03

        let wiggle = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wiggle.values = [-angle, angle]

        wiggle.autoreverses = true
        wiggle.duration = random(interval: 0.1, variance: 0.025)
        wiggle.repeatCount = Float.infinity

        contentView.layer.add(wiggle, forKey: "wiggle")

        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [4.0, 0.0]

        bounce.autoreverses = true
        bounce.duration = random(interval: 0.12, variance: 0.025)
        bounce.repeatCount = Float.infinity

        contentView.layer.add(bounce, forKey: "bounce")
    }

    func stopWiggling() {
        contentView.layer.removeAllAnimations()
    }

    func random(interval: TimeInterval, variance: Double) -> TimeInterval {
        return interval + variance * Double((Double(arc4random_uniform(1000)) - 500.0) / 500.0)
    }

    var isEditing: Bool = false {
        didSet {
            // guard oldValue != isEditing else { return }
            switch isEditing {
            case true:
                startWiggling()
                deleteButton.isHidden = false
            case false:
                stopWiggling()
                deleteButton.isHidden = true
            }
        }
    }

}

extension Reactive where Base: IconCell {
    var isEditing: UIBindingObserver<IconCell, Bool> {
        return UIBindingObserver(UIElement: self.base, binding: { (iconCell, isEditing) in
            // if iconCell.isEditing != isEditing {
            iconCell.isEditing = isEditing
            //}
        })
    }
}
