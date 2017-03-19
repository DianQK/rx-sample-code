//
//  UploadImageTestViewController.swift
//  rx-sample-code
//
//  Created by wc on 19/3/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RandomKit

import Foundation
import MBProgressHUD

class HUD {
    
    private init() { }
    /**
     显示一个提示消息
     
     - parameter message: 显示内容
     */
    static func showMessage(_ message: String) {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        
        hud.mode = MBProgressHUDMode.text
        hud.label.text = message
        hud.margin = 10
        hud.offset.y = 150
        hud.removeFromSuperViewOnHide = true
        hud.isUserInteractionEnabled = false
        
        hud.hide(animated: true, afterDelay: 1)
    }
}

public enum StatusCodeError: Swift.Error {
    case code(Int)
    
    public var code: Int {
        switch self {
        case let .code(code):
            return code
        }
    }

}

extension StatusCodeError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .code(code):
            return "错误的状态码\(code)"
        }
    }
    
}

public enum CustomMessageError: Swift.Error {
    case message(String)
}

extension CustomMessageError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .message(message):
            return message
        }
    }
    
}

extension Reactive where Base: URLSession {
    
    public func statusCode(url: URL) -> Observable<Int> {
        return response(request: URLRequest(url: url))
            .map { (response, data) -> Int in
                if 200 ..< 300 ~= response.statusCode {
                    return response.statusCode
                }
                else {
                    throw StatusCodeError.code(response.statusCode)
                }
        }
    }
    
}

extension ObservableConvertibleType {
    
    public func asDriverJustShowErrorMessage() -> Driver<E> {
        return self.asObservable()
            .asDriver(onErrorRecover: { (error) -> Driver<E> in
                HUD.showMessage(error.localizedDescription)
                return Driver.empty()
            })
    }
    
}

class UploadImageTestViewController: UIViewController {

    @IBOutlet weak var uploadImageButton: UIButton!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicator = ActivityIndicator()
        
        activityIndicator
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)

        uploadImageButton.rx.tap.asDriver()
            .flatMap { [unowned self] () -> Driver<()> in
                Observable
                    .deferred({ () -> Observable<Int> in
                        let url = URL(string: "https://httpbin.org/status/\([200, 503, 599].random!)?type=upload")!
                        return URLSession.shared.rx.statusCode(url: url)
                    })
                    .map { _ in }
                    .trackActivity(activityIndicator)
                    .retryWhen { (errorObservable: Observable<StatusCodeError>) -> Observable<()> in
                        errorObservable
                            .flatMap {  error -> Observable<()> in
                                switch error {
                                case let .code(code):
                                    if code == 503 {
                                        return Observable.error(error)
                                    }
                                    return showAlert(title: "上传图片时遇到了一个错误，是否重试？", message: "错误的状态码\(code)", for: self)
                                        .map { isEnsure in
                                            if isEnsure {
                                                return ()
                                            } else {
                                                throw CustomMessageError.message("您取消了本次的上传操作")
                                            }
                                    }
                                }
                        }
                    }
                    .asDriverJustShowErrorMessage()
            }
            .flatMap { [unowned self] () -> Driver<()> in
                Observable
                    .deferred({ () -> Observable<Int> in
                        let url = URL(string: "https://httpbin.org/status/\([200, 503, 408].random!)?type=request")!
                        return URLSession.shared.rx.statusCode(url: url)
                    })
                    .map { _ in }
                    .trackActivity(activityIndicator)
                    .retryWhen { (errorObservable: Observable<StatusCodeError>) -> Observable<()> in
                        errorObservable
                            .flatMap { error -> Observable<()> in
                                switch error {
                                case let .code(code):
                                    if code == 503 {
                                        return Observable.error(error)
                                    }
                                    return showAlert(title: "网络请求时遇到了一个错误，是否重试？", message: "错误的状态码\(code)", for: self)
                                        .map { isEnsure in
                                            if isEnsure {
                                                return ()
                                            } else {
                                                throw CustomMessageError.message("您取消了本次的请求")
                                            }
                                    }
                                }
                        }
                    }
                    .asDriverJustShowErrorMessage()
            }
            .debug()
            .drive(onNext: {
                HUD.showMessage("上传成功")
            })
            .disposed(by: disposeBag)

        
    }
    
    deinit {
        print("deinit")
    }

}
