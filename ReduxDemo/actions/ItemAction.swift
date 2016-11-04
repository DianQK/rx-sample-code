//
//  ItemAction.swift
//  ReduxDemo
//
//  Created by DianQK on 04/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift

enum ItemAction {
    case modifyItem(IconItem)
    case modifyTitle(String)
    case modifyImage(UIImage)
    case cancelModify
    case saveModify
}
