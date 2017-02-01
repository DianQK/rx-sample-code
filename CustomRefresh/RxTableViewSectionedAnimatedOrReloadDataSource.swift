//
//  RxTableViewSectionedAnimatedOrReloadDataSource.swift
//  CustomRefresh
//
//  Created by wc on 24/12/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public struct RefreshSectionList<S: AnimatableSectionModelType> {
    
    public var sectionModels: [S]
    public var isRefresh: Bool
    
    public init(sectionModels: [S], isRefresh: Bool) {
        self.sectionModels = sectionModels
        self.isRefresh = isRefresh
    }
    
}

open class RxTableViewSectionedAnimatedOrReloadDataSource<S: AnimatableSectionModelType>: TableViewSectionedDataSource<S> , RxTableViewDataSourceType {
    
    public typealias Element = RefreshSectionList<S>
    public var animationConfiguration = AnimationConfiguration()
    
    open func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSectionlist in
            if newSectionlist.isRefresh {
                dataSource.setSections(newSectionlist.sectionModels)
                tableView.reloadData()
            }
            else {
                DispatchQueue.main.async {
                    let oldSections = dataSource.sectionModels
                    do {
                        let differences = try differencesForSectionedView(initialSections: oldSections, finalSections: newSectionlist.sectionModels)
                        
                        for difference in differences {
                            dataSource.setSections(difference.finalSections)
                            
                            tableView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                        }
                    }
                    catch let e {
                        print(e)
                        self.setSections(newSectionlist.sectionModels)
                        tableView.reloadData()
                    }
                }
            }
            }.on(observedEvent)
    }
}
