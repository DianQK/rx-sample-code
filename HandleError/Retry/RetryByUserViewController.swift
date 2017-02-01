
//  RetryByUserViewController.swift
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

public func showAlert(title: String?, message: String?, for viewController: UIViewController) -> Observable<Bool> {
    return Observable.create { [weak viewController] observer in
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            observer.on(.next(false))
            observer.on(.completed)
        }))
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
            observer.on(.next(true))
            observer.on(.completed)
        }))
        viewController?.present(alert, animated: true, completion: nil)
        return Disposables.create {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

class RetryByUserViewController: UIViewController {

    @IBOutlet private weak var requestButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        /// 自定义的错误
        ///
        /// - notPositive: 不是正数
        /// - oversize: 数字过大
        enum MyError: Swift.Error, LocalizedError {
            case notPositive(value: Int)
            case oversize(value: Int)

            var errorDescription: String? {
                switch self {
                case let .notPositive(value):
                    return "\(value)不是正数"
                case let .oversize(value):
                    return "\(value)过大"
                }
            }
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
            .debug()
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
            .disposed(by: disposeBag)

    }

}
