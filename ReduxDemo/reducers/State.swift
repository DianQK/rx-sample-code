//
//  State.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import RxSwift

protocol ReducerAction {
    associatedtype ActionType
    mutating func reducer(_ action: ActionType)
}

/// 全局 state
var _state = State()

struct State: ReducerAction {

    mutating func reducer(_ action: Action) {
        switch action {
        case let .collection(action):
            collection.reducer(action)
        case let .item(action):
            item.reducer(action)
        }
    }

    typealias ActionType = Action

    lazy var collection = CollectionState()

    lazy var item = ItemState()
    
}
