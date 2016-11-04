//
//  AutomaticCollectionViewFlowLayout.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 02/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit

class AutomaticCollectionViewFlowLayout: UICollectionViewFlowLayout {

    private var _indexPathsToAnimate: [IndexPath] = []

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        _indexPathsToAnimate = updateItems
            .flatMap { updateItem -> IndexPath? in
                switch updateItem.updateAction {
                case .insert:
                    return updateItem.indexPathAfterUpdate
                case .delete:
                    return updateItem.indexPathBeforeUpdate
                case .none, .reload, .move:
                    return nil
                }
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        _indexPathsToAnimate = []
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        guard let attr = layoutAttributesForItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        if let index = _indexPathsToAnimate.index(of: itemIndexPath) {
            attr.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            attr.alpha = 0.3
            _indexPathsToAnimate.remove(at: index)
        }

        return attr
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let index = _indexPathsToAnimate.index(of: itemIndexPath) {
            _indexPathsToAnimate.remove(at: index)
            return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        } else {
            return layoutAttributesForItem(at: itemIndexPath)
        }
    }

}
