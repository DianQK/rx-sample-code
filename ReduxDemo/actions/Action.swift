//
//  Action.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift

enum Action {
    case collection(CollectionAction)
    case item(ItemAction)
}
