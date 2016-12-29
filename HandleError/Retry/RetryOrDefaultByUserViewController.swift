//
//  RetryOrDefaultByUserViewController.swift
//  HandleError
//
//  Created by DianQK on 29/12/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxExtensions
import RandomKit

class RetryOrDefaultByUserViewController: UIViewController {

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()


        /// 自定义的错误
        ///
        /// - notPositive: 不是正数
        /// - oversize: 数字过大
        enum MyError: Swift.Error {
            case notPositive(value: Int)
            case oversize(value: Int)
        }

        Observable<Int>
            .deferred { () -> Observable<Int> in
                return Observable.just(Int.random(within: -100...200))
            }
            .map { value -> Int in
                if value <= 0 {
                    throw MyError.notPositive(value: value)
                } else if value > 100 {
                    throw MyError.oversize(value: value)
                } else {
                    return value
                }
            }
            .retryWhen { [unowned self] (errorObservable: Observable<MyError>) -> Observable<()> in
                errorObservable
                    .flatMap { error -> Observable<()> in
                        switch error {
                        case let .notPositive(value):
                            return showAlert(title: "遇到了一个错误，是否重试？", message: "错误信息\(value) 小于 0", for: self)
                                .map { isEnsure in
                                    if isEnsure {
                                        return ()
                                    } else {
                                        throw error
                                    }
                            }
                        case .oversize:
                            return Observable.error(error)
                        }
                }
            }
            .debug()
            .subscribe()
            .addDisposableTo(disposeBag)
        
    }
    
}
