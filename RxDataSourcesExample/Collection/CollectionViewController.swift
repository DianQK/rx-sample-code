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

    private let items = Variable<[IconItem]>((1...10).map { IconItem(logo: R.image.dianQK()!, title: "\($0)", id: $0) })

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
            state.asObservable()
                .map { $0.actionBarTitle }
                .bindTo(actionBarButtonItem.rx.title)
                .disposed(by: rx.disposeBag)

            actionBarButtonItem
                .rx.tap
                .withLatestFrom(state.asObservable())
                .reverse()
                .bindTo(state)
                .disposed(by: rx.disposeBag)
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
                        .disposed(by: cell.prepareForReuseBag)
                    self.state.asObservable()
                        .map { $0.isEditing }
                        .bindTo(cell.rx.isEditing)
                        .disposed(by: cell.prepareForReuseBag)
                }
                return cell
            }

            dataSource.moveItem = { [unowned self] dataSource, sourceIndexPath, destinationIndexPath in
                var value = self.items.value
                let temp = value.remove(at: sourceIndexPath.row)
                value.insert(temp, at: destinationIndexPath.row)
                self.items.value = value
            }

            Observable
                .combineLatest(items.asObservable(), state.asObservable()) { items, state -> [IconItem] in
                    switch state {
                    case .editing:
                        return items
                    case .viewing:
                        return items + [IconItem(logo: R.image.btn_add()!, title: "Add", id: 0)]
                    }
                }
                .map { [IconSectionModel(model: "", items: $0)] }
                .bindTo(collectionView.rx.items(dataSource: dataSource))
                .disposed(by: rx.disposeBag)
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
                    case .ended:
                        self.collectionView.endInteractiveMovement()
                    case .cancelled, .failed, .possible:
                        self.collectionView.cancelInteractiveMovement()
                    }
                })
                .disposed(by: rx.disposeBag)
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
                    HUD.showMessage(item.title)
                })
                .disposed(by: rx.disposeBag)
        }

    }

}
