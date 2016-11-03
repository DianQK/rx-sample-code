//
//  CollectionAction.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift

enum CollectionAction {
    case add(item: IconItem)
    case remove(item: IconItem)
    case move(sourceIndex: Int, destinationIndex: Int)
    case edit
    case done
    case change // =.= 更新是 edit 还是 done
}
