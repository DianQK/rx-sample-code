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

extension ObservableType {

    public func retryWithBinaryExponentialBackoff(maxAttemptCount: Int, interval: TimeInterval) -> Observable<Self.E> {
        return self.asObservable()
            .retryWhen { (errorObservable: Observable<Swift.Error>) -> Observable<()> in
                errorObservable
                    .scan((currentCount: 0, error: Optional<Swift.Error>.none), accumulator: { a, error in
                        return (currentCount: a.currentCount + 1, error: error)
                    })
                    .flatMap({ (currentCount, error) -> Observable<()> in
                        return ((currentCount > maxAttemptCount) ? Observable.error(error!) : Observable.just(()))
                            .delay(pow(2, Double(currentCount)) * interval, scheduler: MainScheduler.instance)
                    })
            }
    }

}

class RetryOrDefaultByUserViewController: UIViewController {

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
                return Observable.just(-100)
//                return Observable.just(Int.random(within: -100...200))
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
            .retryWithBinaryExponentialBackoff(maxAttemptCount: 10, interval: 1)



//            .catchError { (error) -> Observable<Int> in
//                return Observable.create { [unowned self] observer in
//                    let alert = UIAlertController(title: "遇到了一个错误，重试还是使用默认值 1 替换？", message: "错误信息：\(error.localizedDescription)", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "重试", style: .cancel, handler: { _ in
//                        observer.on(.error(error))
//                    }))
//                    alert.addAction(UIAlertAction(title: "替换", style: .default, handler: { _ in
//                        observer.on(.next(1))
//                        observer.on(.completed)
//                    }))
//                    self.present(alert, animated: true, completion: nil)
//                    return Disposables.create {
//                        alert.dismiss(animated: true, completion: nil)
//                    }
//                }
//            }
//            .retry()
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
}
