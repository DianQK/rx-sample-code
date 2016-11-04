//
//  ItemState.swift
//  ReduxDemo
//
//  Created by DianQK on 04/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxExtensions

struct ItemState: ReducerAction {

    typealias ActionType = ItemAction

    lazy private(set) var modifyItem = Variable<IconItem?>(nil)
    lazy private(set) var modifyImage = Variable<UIImage?>(nil)
    lazy private(set) var modifyTitle = Variable<String?>(nil)

    mutating func reducer(_ action: ItemAction) {
        switch action {
        case let .modifyItem(item):
            modifyItem.value = item
        case let  .modifyImage(image):
            modifyImage.value = image
        case let .modifyTitle(title):
            modifyTitle.value = title
        case .saveModify:
            guard let item = modifyItem.value else { return }
            if let image = modifyImage.value {
                item.logo.value = image
            }
            if let title = modifyTitle.value {
                item.title.value = title
            }
            modifyItem.value = nil
        case .cancelModify:
            modifyItem.value = nil
        }
    }
    
}
