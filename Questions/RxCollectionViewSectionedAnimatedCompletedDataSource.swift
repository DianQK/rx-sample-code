//
//  RxCollectionViewSectionedAnimatedCompletedDataSource.swift
//  Questions
//
//  Created by DianQK on 10/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class RxCollectionViewSectionedAnimatedCompletedDataSource<S : AnimatableSectionModelType>: RxCollectionViewSectionedAnimatedDataSource<S> {

    var performBatchUpdatesCompletion: (() -> ())?


    /**
     This method exists because collection view updates are throttled because of internal collection view bugs.
     Collection view behaves poorly during fast updates, so this should remedy those issues.
     */
    open override func collectionView(_ collectionView: UICollectionView, throttledObservedEvent event: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSections in
            let oldSections = dataSource.sectionModels
            do {
                let differences = try differencesForSectionedView(initialSections: oldSections, finalSections: newSections)

                for difference in differences {
                    dataSource.setSections(difference.finalSections)

//                    collectionView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)

                    collectionView.performBatchUpdates({ 
                        _performBatchUpdates(collectionView, changes: difference)
                    }, completion: { _ in
                        self.performBatchUpdatesCompletion?()
                    })
                }
            }
            catch let e {
                #if DEBUG
                    print("Error while binding data animated: \(e)\nFallback to normal `reloadData` behavior.")
//                    rxDebugFatalError(e)
                #endif
                self.setSections(newSections)
                collectionView.reloadData()
            }
            }.on(event)
    }

}


func _performBatchUpdates<V: SectionedViewType, S: SectionModelType>(_ view: V, changes: Changeset<S>) {
    typealias I = S.Item

    view.deleteSections(changes.deletedSections, animationStyle: UITableViewRowAnimation.automatic)
    // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
    // otherwise all cells will be reloaded for nothing.
    //view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
    view.insertSections(changes.insertedSections, animationStyle: UITableViewRowAnimation.automatic)
    for (from, to) in changes.movedSections {
        view.moveSection(from, to: to)
    }

    view.deleteItemsAtIndexPaths(
        changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: UITableViewRowAnimation.automatic
    )
    view.insertItemsAtIndexPaths(
        changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: UITableViewRowAnimation.automatic
    )
    view.reloadItemsAtIndexPaths(
        changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: UITableViewRowAnimation.automatic
    )

    for (from, to) in changes.movedItems {
        view.moveItemAtIndexPath(
            IndexPath(item: from.itemIndex, section: from.sectionIndex),
            to: IndexPath(item: to.itemIndex, section: to.sectionIndex)
        )
    }
}
