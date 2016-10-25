//
//  CollectionViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 01/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

import MBProgressHUD

class HUD {

    private init() { }
    /**
     显示一个提示消息

     - parameter message: 显示内容
     */
    static func showMessage(_ message: String) {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)

        hud.mode = MBProgressHUDMode.text
        hud.label.text = message
        hud.margin = 10
        hud.offset.y = 150
        hud.removeFromSuperViewOnHide = true
        hud.isUserInteractionEnabled = false

        hud.hide(animated: true, afterDelay: 1)
    }
}

class IconCell: ReactiveCollectionViewCell {

    @IBOutlet fileprivate weak var iconImageView: UIImageView! {
        didSet {
            self.iconImageView.layer.cornerRadius = 8.0
            self.iconImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var deleteButton: UIButton!

    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set(isHighlighted) {
            super.isHighlighted = isHighlighted
        }
    }

    func startWiggling() {
        guard contentView.layer.animation(forKey: "wiggle") == nil else { return }
        guard contentView.layer.animation(forKey: "bounce") == nil else { return }

        let angle = 0.04

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

struct IconItem: IDHashable, IdentifiableType {
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        return id.hashValue
    }

    let logo: UIImage
    let title: String
    let id: Int64

    var identity: Int64 {
        return id
    }

    init(logo: UIImage, title: String, id: Int64) {
        self.logo = logo
        self.title = title
        self.id = id
    }
}

typealias IconSectionModel = AnimatableSectionModel<String, IconItem>

class CollectionViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var actionBarButtonItem: UIBarButtonItem!

    private let dataSource = RxCollectionViewSectionedAnimatedDataSource<IconSectionModel>()

    private let items = Variable<[IconItem]>([])

    enum State: Reverseable {
        case editing
        case viewing

        var actionBarTitle: String {
            switch self {
            case .editing:
                return "Done"
            case .viewing:
                return "Edit"
            }
        }

        var reverseValue: State {
            switch self {
            case .editing: return .viewing
            case .viewing: return .editing
            }
        }

        var isEditing: Bool {
            switch self {
            case .editing: return true
            default: return false
            }
        }
    }

    let state = Variable(State.viewing)

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            items.value = (1...10).map { IconItem(logo: R.image.dianQK()!, title: "\($0)", id: $0) }
        }

        do {
            state.asObservable()
                .map { $0.actionBarTitle }
                .bindTo(actionBarButtonItem.rx.title)
                .addDisposableTo(rx.disposeBag)

            actionBarButtonItem
                .rx.tap
                .withLatestFrom(state.asObservable())
                .reverse()
                .bindTo(state)
                .addDisposableTo(rx.disposeBag)
        }

        do {
            dataSource.configureCell = { [unowned self] dataSource, collectionView, indexPath, element in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.iconCell, for: indexPath)!
                cell.iconImageView.image = element.logo
                cell.titleLabel.text = element.title
                // 暂时以 id = 0 认为是添加 item 的 cell
                if element.id == 0 {
                    cell.deleteButton.isHidden = true
                } else {
                    cell.deleteButton.rx.tap
                        .subscribe(onNext: {
                            guard let index = self.items.value.index(of: element) else { return }
                            self.items.value.remove(at: index)
                        })
                        .addDisposableTo(cell.prepareForReuseBag)
                    self.state.asObservable()
                        .map { $0.isEditing }
                        .bindTo(cell.rx.isEditing)
                        .addDisposableTo(cell.prepareForReuseBag)
                }
                return cell
            }

            dataSource.moveItem = { [unowned self] dataSource, sourceIndexPath, destinationIndexPath in
                var value = self.items.value
                let temp = value.remove(at: sourceIndexPath.row)
                value.insert(temp, at: destinationIndexPath.row)
                self.items.value = value
            }

            dataSource.canMoveItemAtIndexPath = { dataSource, indexPath in
                return indexPath.row < self.items.value.count
            }

            items
                .asObservable()
                .map { $0 + [IconItem(logo: R.image.btn_add()!, title: "Add", id: 0)] }
                .map { [IconSectionModel(model: "", items: $0)] }
                .bindTo(collectionView.rx.items(dataSource: dataSource))
                .addDisposableTo(rx.disposeBag)
        }

        do {

            let long = UILongPressGestureRecognizer()
            long.rx.event
                .subscribe(onNext: { [unowned self] gesture in
                    switch gesture.state {
                    case .began:
                        guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                            break
                        }
                        self.state.value = .editing
                        self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
                    case .changed:
                        self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
                        break
                        // 目的 IndexPath
                        guard let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                            // self.collectionView.cancelInteractiveMovement()
                            break
                        }
                        if indexPath.row < self.items.value.count {
                            self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
                        }
                    case .ended:
                        self.collectionView.endInteractiveMovement()
                    case .cancelled, .failed, .possible:
                        self.collectionView.cancelInteractiveMovement()
                    }
                })
                .addDisposableTo(rx.disposeBag)
            self.collectionView.addGestureRecognizer(long)

        }

        do {
            collectionView
                .rx.modelSelected(IconItem.self)
                .subscribe(onNext: { item in
                    if item.id == 0 {
                        let nextID = (self.items.value.max(by: { $0.id < $1.id })?.id ?? 0) + 1
                        self.items.value.append(IconItem(logo: R.image.dianQK()!, title: "\(nextID)", id: Int64(nextID)))
                        return
                    }
                    guard !self.state.value.isEditing else { return }
                    print(item.id)
                    HUD.showMessage(item.title)
                })
                .addDisposableTo(rx.disposeBag)

            collectionView
                .rx.itemSelected
                .subscribe(onNext: { ip in
                    print(ip)
                })
                .addDisposableTo(rx.disposeBag)
        }

    }

}
