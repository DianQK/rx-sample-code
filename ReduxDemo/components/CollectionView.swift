//
//  CollectionView.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions
import RxDataSources

class CollectionView: ReactiveCollectionView {

    private typealias IconSectionModel = AnimatableSectionModel<String, IconItem>

    private let _dataSource = RxCollectionViewSectionedAnimatedDataSource<IconSectionModel>()

    override func commonInit() {
      _dataSource.configureCell = { dataSource, collectionView, indexPath, element in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.iconCell, for: indexPath)!
            cell.item.onNext(element)
            return cell
        }

        _dataSource.moveItem = { dataSource, sourceIndexPath, destinationIndexPath in
            dispatch(Action.collection(.move(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)))
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
            .bindTo(self.rx.items(dataSource: _dataSource))
            .addDisposableTo(disposeBag)

        let long = UILongPressGestureRecognizer()
        long.rx.event
            .subscribe(onNext: { [unowned self] gesture in
                switch gesture.state {
                case .began:
                    guard let selectedIndexPath = self.indexPathForItem(at: gesture.location(in: self)) else {
                        break
                    }
                    dispatch(Action.collection(.edit))
                    self.beginInteractiveMovementForItem(at: selectedIndexPath)
                case .changed:
                    self.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
                case .ended:
                    self.endInteractiveMovement()
                case .cancelled, .failed, .possible:
                    self.cancelInteractiveMovement()
                }
            })
            .addDisposableTo(disposeBag)
        self.addGestureRecognizer(long)

        self.rx.modelSelected(IconItem.self)
            .subscribe(onNext: { item in
                if item.id == 0 {
                    let nextID = (state.collection.elements.value.max(by: { $0.id < $1.id })?.id ?? 0) + 1
                    dispatch(Action.collection(.add(item: IconItem(id: nextID, logo: R.image.dianQK()!, title: "\(nextID)"))))
                    return
                }
                guard !state.collection.isEditing.value else { return }
                HUD.showMessage(item.title)
            })
            .addDisposableTo(disposeBag)
    }

}
