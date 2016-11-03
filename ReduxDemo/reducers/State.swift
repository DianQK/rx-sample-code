//
//  State.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import RxSwift

protocol HandleAction {
    associatedtype ActionType
    mutating func handle(_ action: ActionType)
}

var state = State()

struct State: HandleAction {

    mutating func handle(_ action: Action) {
        switch action {
        case let .collection(action):
            collection.handle(action)
        }
    }

    typealias ActionType = Action

    fileprivate init() { }

    lazy var collection = CollectionState()
    
}
