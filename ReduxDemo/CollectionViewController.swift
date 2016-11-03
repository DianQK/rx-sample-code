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

typealias IconSectionModel = AnimatableSectionModel<String, IconItem>

class CollectionViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var actionBarButtonItem: UIBarButtonItem!

    private let dataSource = RxCollectionViewSectionedAnimatedDataSource<IconSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            state.collection
                .isEditing.asObservable()
                .map { $0 ? "Done" : "Edit" }
                .bindTo(actionBarButtonItem.rx.title)
                .addDisposableTo(rx.disposeBag)

            actionBarButtonItem
                .rx.tap.asObservable()
                .map { Action.collection(CollectionAction.change) }
                .dispatch()
                .addDisposableTo(rx.disposeBag)
        }

        do {
            dataSource.configureCell = { dataSource, collectionView, indexPath, element in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.iconCell, for: indexPath)!
                cell.iconImageView.image = element.logo
                cell.titleLabel.text = element.title
                // 暂时以 id = 0 认为是添加 item 的 cell
                if element.id == 0 {
                    cell.deleteButton.isHidden = true
                } else {
                    cell.deleteButton.rx.tap
                        .map { Action.collection(CollectionAction.remove(item: element)) }
                        .dispatch()
                        .addDisposableTo(cell.prepareForReuseBag)
                    state.collection
                        .isEditing.asObservable()
                        .bindTo(cell.rx.isEditing)
                        .addDisposableTo(cell.prepareForReuseBag)
                }
                return cell
            }

            dataSource.moveItem = { dataSource, sourceIndexPath, destinationIndexPath in
                dispatch(Action.collection(CollectionAction.move(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)))
            }

            Observable
                .combineLatest(state.collection.elements.asObservable(), state.collection.isEditing.asObservable()) { items, isEditing -> [IconItem] in
                    switch isEditing {
                    case true:
                        return items
                    case false:
                        return items + [IconItem(id: 0, logo: R.image.btn_add()!, title: "Add")]
                    }
                }
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
                        dispatch(Action.collection(CollectionAction.edit))
                        self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
                    case .changed:
                        self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
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
                        let nextID = (state.collection.elements.value.max(by: { $0.id < $1.id })?.id ?? 0) + 1
                        dispatch(Action.collection(CollectionAction.add(item: IconItem(id: 0, logo: R.image.dianQK()!, title: "\(nextID)"))))
                        return
                    }
                    guard !state.collection.isEditing.value else { return }
                    HUD.showMessage(item.title)
                })
                .addDisposableTo(rx.disposeBag)
        }

    }

}
