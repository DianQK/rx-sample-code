//
//  Dispatch.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import RxSwift

let dispatch: (Action) -> Void = { action in
    _state.reducer(action)
}

protocol ActionValue {
    var value: Action { get }
}
extension Action: ActionValue {
    var value: Action {
        return self
    }

}

extension ObservableType where E: ActionValue {
    func dispatch() -> Disposable {
        return asObservable()
            .subscribe(onNext: { action in
                _state.reducer(action.value)
            })
    }
}
