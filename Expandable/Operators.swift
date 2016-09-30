//
//  Operators.swift
//  RxDealCell
//
//  Created by DianQK on 8/4/16.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

infix operator <->

    func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    if T.self == String.self {
        #if DEBUG
            fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx_text` property directly to variable.\n" +
                "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
                "REMEDY: Just use `textField <-> variable` instead of `textField.rx_text <-> variable`.\n" +
                "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
            )
        #endif
    }

    let bindToUIDisposable = variable.asObservable()
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
        variable.value = n
        }, onCompleted: {
            bindToUIDisposable.dispose()
    })

    return Disposables.create(bindToUIDisposable, bindToVariable)
}

func <-> <T: Equatable>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    if T.self == String.self {
        //        #if DEBUG
        //            fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx_text` property directly to variable.\n" +
        //                "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
        //                "REMEDY: Just use `textField <-> variable` instead of `textField.rx_text <-> variable`.\n" +
        //                "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
        //            )
        //        #endif
    }

    let bindToUIDisposable = variable.asObservable()
        .distinctUntilChanged()
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
        variable.value = n
        }, onCompleted: {
            bindToUIDisposable.dispose()
    })

    return Disposables.create(bindToUIDisposable, bindToVariable)
}

func <-> <T: Equatable>(lhs: Variable<T>, rhs: Variable<T>) -> Disposable {

    let bindToUIDisposable = lhs.asObservable()
        .distinctUntilChanged()
        .bindTo(rhs)
    let bindToVariable = rhs.asObservable()
        .distinctUntilChanged()
        .bindTo(lhs)

    return Disposables.create(bindToUIDisposable, bindToVariable)
}
