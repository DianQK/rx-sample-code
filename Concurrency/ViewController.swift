//
//  ViewController.swift
//  Concurrency
//
//  Created by DianQK on 01/02/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

let convertToRequest: (Int) -> URLRequest = {
    print("request \($0)")
    return URLRequest(url: URL(string: "https://httpbin.org/get?foo=\($0)")!)
}

let prase: (Data) -> JSON = {
    let json = JSON(data: $0)
    print(json["args"]["foo"])
    print("-------")
    return json
}

extension Reactive where Base: URLSession {

    public func customJSON(request: URLRequest) -> Observable<JSON> {
        return Observable.create { observer in

            let task = self.base.dataTask(with: request) { (data, response, error) in

                guard let response = response, let data = data else {
                    observer.on(.error(error ?? RxCocoaURLError.unknown))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.on(.error(RxCocoaURLError.nonHTTPResponse(response: response)))
                    return
                }

                guard 200 ..< 300 ~= httpResponse.statusCode else {
                    observer.on(.error(RxCocoaURLError.httpRequestFailed(response: httpResponse, data: data)))
                    return
                }

                let json = JSON(data: data)

                print("Success: \(json)")

                observer.on(.next(json))
                observer.on(.completed)
            }


            let t = task
            t.resume()
            print("Request \(request.url!)")
            
            return Disposables.create(with: task.cancel)
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet private weak var concurrencyButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        concurrencyButton
            .rx.tap
            .flatMap {
                Observable.from([1, 2, 3, 4, 5, 6, 7])
                    .map(convertToRequest)
                    .map(URLSession.shared.rx.customJSON)
                    .concat()
                    .map { $0["args"]["foo"].stringValue }
                    .toArray()
                    .reduce(Array<String>(), accumulator: +)
            }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)


        //        concurrencyButton
        //            .rx_tap
        //            .flatMap { [1, 2, 3, 4, 5, 6, 7].toObservable() }
        //            .map(convertToRequest)
        //            .map(NSURLSession.sharedSession().rx_data)
        //            .concat()
        //            .map(prase)
        //            .map { $0["args"]["foo"].stringValue }
        //            .toArray()
        //            .reduce(Array<String>(), accumulator: +)
        //            .subscribeNext {
        //                print($0)
        //            }
        //            .disposed(by: disposeBag)


    }

}

