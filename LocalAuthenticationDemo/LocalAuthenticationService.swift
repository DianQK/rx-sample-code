//
//  LocalAuthenticationService.swift
//  rx-sample-code
//
//  Created by DianQK on 28/03/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import LocalAuthentication

extension Reactive where Base: UIAlertController {
    static func createWithParent<Element>(_ parent: UIViewController? = UIApplication.topViewController(), title: String? = nil, message: String? = nil, configureAlert: ((UIAlertController, AnyObserver<Element>) throws -> (Disposable?))? = nil) -> Observable<Element> {
        return Observable.create { [weak parent] observer in
            MainScheduler.ensureExecutingOnScheduler()
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            var configureDisposable = nil as Disposable?
            do {
                configureDisposable = try configureAlert?(alert, observer)
            } catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }

            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }

            parent.present(alert, animated: true, completion: nil)

            let dismissDisposable = Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }

            if let configureDisposable = configureDisposable {
                return Disposables.create([dismissDisposable, configureDisposable])
            } else {
                return dismissDisposable
            }
        }
    }

    static func createWithParent<Element>(_ parent: UIViewController? = UIApplication.topViewController(), title: String? = nil, message: String? = nil, configureAlert: ((UIAlertController, AnyObserver<Element>) throws -> ())? = nil) -> Observable<Element> {
        return createWithParent(parent, title: title, message: message, configureAlert: { (alert, observer) -> (Disposable?) in
            try configureAlert?(alert, observer)
            return nil
        })
    }
}


func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }

        return
    }

    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}


func validate(password: String) -> Observable<Bool> {
    return Observable.just(password == "123")
}

class LocalStorage {

    static var isTouchIDOpened: Bool? = nil

}


/// 认证错误
///
/// - invalidPassword: 密码不对
/// - cancelInputPassword: 用户取消了输入密码
/// - cancelTouchID: 取消了 Touch ID 验证
/// - touchIDAuthenticationFailed: TouchID 验证错误
/// - needResetPassword: 需要重置密码
/// - cannotEvaluatePolicy: Touch ID 验证不可用
enum AuthorizeError: Swift.Error {

    case invalidPassword
    case cancelInputPassword
    case cancelTouchID
    case touchIDAuthenticationFailed
    case needResetPassword
    case cannotEvaluatePolicy

}

class LocalAuthenticationUnit {

    private static var evaluatePolicy: LAPolicy {
        if #available(iOS 9.0, *) {
            return LAPolicy.deviceOwnerAuthentication
        } else {
            return LAPolicy.deviceOwnerAuthenticationWithBiometrics
        }
    }

    /// 单一功能，弹出密码认证输入框
    ///
    /// - Returns: 认证结果，true 为正确
    static func showAuthorizeWithPassword() -> Observable<Bool> {
        return UIAlertController.rx.createWithParent(title: "安全验证", message: "为了您的账户安全，请输入登录密码", configureAlert: { (alert, observer: AnyObserver<String>) -> Disposable? in
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "请输入账户登录密码"
                textField.isSecureTextEntry = true
            })
            let passwordField = alert.textFields!.first!
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { _ in
                observer.onCompleted()
            })
            let confirmAction = UIAlertAction(title: "确定", style: .destructive) { _ in
                guard let password = passwordField.text else {
                    observer.onCompleted()
                    return
                }
                observer.onNext(password)
                observer.onCompleted()
            }

            alert.addAction(confirmAction)
            alert.addAction(cancelAction)

            return passwordField.rx.text.asObservable()
                .map { $0?.isEmpty == false }
                .takeUntil(passwordField.rx.deallocated)
                .bindTo(confirmAction.rx.isEnabled)
            })
            .flatMapFirst { (password) in validate(password: password) }
            .observeOn(MainScheduler.instance)
            .map { isSuccess -> Bool in
                if isSuccess {
                    return isSuccess
                } else {
                    throw AuthorizeError.invalidPassword
                }
        }
    }

    /// 判断是否可以打开 Touch ID
    ///
    /// - Parameter touchIDContext: Context
    /// - Returns: 可以则传递一个值，不可以则抛出错误 AuthorizeError.cannotEvaluatePolicy
    static func canEvaluatePolicy(touchIDContext: LAContext = LAContext()) -> Observable<()> {
        return Observable.deferred { () -> Observable<()> in
            if touchIDContext.canEvaluatePolicy(self.evaluatePolicy, error: nil) {
                return Observable.just(())
            } else {
                return Observable.error(AuthorizeError.cannotEvaluatePolicy)
            }
        }
    }

    static var canEvaluatePolicy: Bool {
        return LAContext().canEvaluatePolicy(self.evaluatePolicy, error: nil)
    }

    /// 单纯地进行 Touch ID 认证，可能抛出错误，建议先验证 Touch ID 是否可用
    ///
    /// - Parameter touchIDContext: Context
    /// - Returns: Touch ID 认证结果，Bool 值一定为 true ，认证失败抛出错误 AuthorizeError ，可能为 .cancelTouchID 和 .touchIDAuthenticationFailed
    static func showTouchIDAuth(touchIDContext: LAContext = LAContext()) -> Observable<Bool> {
        return Observable
            .create { (observer) -> Disposable in
                touchIDContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "输入正确的指纹，验证进入设置", reply: { isSuccess, error in
                    if let error = error, !isSuccess { // 有错误，并且不成功表示认证失败
                        if let error = error as? LAError {
                            switch error.code {
                            case .authenticationFailed:
                                observer.onError(AuthorizeError.touchIDAuthenticationFailed)
                            default:
                                observer.onError(AuthorizeError.cancelTouchID)
                            }
                        } else {
                            observer.onError(AuthorizeError.cancelTouchID)
                        }
                    } else {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                })
                return Disposables.create()
            }
            .observeOn(MainScheduler.instance)
    }

    /// 返回一个重置密码的 Observable ，取消时，抛出 AuthorizeError.needResetPassword 错误
    static func showRetryOnPassword() -> Observable<()> {
        return UIAlertController.rx.createWithParent(title: "验证失败", message: "您输入的登录密码不正确", configureAlert: { (alert, observer: AnyObserver<()>) -> () in
            let resetPasswordAction = UIAlertAction(title: "重置密码", style: .destructive, handler: { _ in
                /// 抛出需要重置密码的错误
                observer.onError(AuthorizeError.needResetPassword)
            })
            let againAction = UIAlertAction(title: "再试一次", style: .default, handler: { _ in
                // 重新认证
                observer.onNext(())
                observer.onCompleted()
            })
            alert.addAction(resetPasswordAction)
            alert.addAction(againAction)
        })
    }

    /// 询问是否打开 Touch ID
    ///
    /// - Returns: 是否打开 Touch ID 结果
    static func showIsEnableTouchIDOption() -> Observable<Bool> {
        return UIAlertController.rx.createWithParent(title: "开启指纹解锁", message: "输入正确的指纹开启指纹解锁，使用指纹解锁进入设置", configureAlert: { (alert, observer: AnyObserver<Bool>) -> () in
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { _ in
                observer.onNext(false)
                observer.onCompleted()
            })
            let confirmAction = UIAlertAction(title: "确定", style: .destructive) { _ in
                observer.onNext(true)
                observer.onCompleted()
            }
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
        })
    }

}

class LocalAuthenticationService {

    /// 判断 Touch ID 是否可用
    static var canEvaluatePolicy: Bool {
        return LocalAuthenticationUnit.canEvaluatePolicy
    }

    /// 非单纯的认证密码，当密码不对时，会进行 retry
    ///
    /// - Returns: 认证结果
    static func showAuthorizeWithPassword() -> Observable<Bool> {
        return LocalAuthenticationUnit.showAuthorizeWithPassword()
            .retryWhen({ (errorObservable: Observable<AuthorizeError>) -> Observable<()> in
                errorObservable
                    .flatMapLatest({ (authorizeError) -> Observable<()> in
                        switch authorizeError {
                        case .invalidPassword:
                            return LocalAuthenticationUnit.showRetryOnPassword()
                        default:
                            return Observable.error(authorizeError)
                        }
                    })
            })
    }

    static func showTouchIDAuth(touchIDContext: LAContext = LAContext()) -> Observable<Bool> {
        return LocalAuthenticationUnit.showTouchIDAuth(touchIDContext: touchIDContext)
            .retryWhen({ (errorObservable: Observable<AuthorizeError>) -> Observable<()> in
                errorObservable
                    .flatMapLatest({ (authorizeError) -> Observable<()> in
                        switch authorizeError {
                        case .touchIDAuthenticationFailed: // Touch ID 认证错误时，重试
                            return Observable.just(())
                        default:
                            return Observable.error(authorizeError)
                        }
                    })
            })
    }


    /// 展示认证
    ///
    /// - Returns: 认证结果
    static func showAuthorize() -> Observable<Bool> {
        return Observable.deferred { () -> Observable<Bool> in
            if let isOpenTouchId = LocalStorage.isTouchIDOpened {
                if isOpenTouchId {
                    let touchIDContext = LAContext()
                    return LocalAuthenticationUnit.canEvaluatePolicy(touchIDContext: touchIDContext) // 验证 Touch ID 是否可用
                        .flatMap {
                            showTouchIDAuth(touchIDContext: touchIDContext) // 可用则进行 Touch ID 认证
                        }
                        .catchError({ (error) -> Observable<Bool> in
                            if let error = error as? AuthorizeError, error == AuthorizeError.cancelTouchID || error == AuthorizeError.cannotEvaluatePolicy { // 取消 Touch ID 认证或者 Touch ID 不可用时，切换到密码认证
                                return LocalAuthenticationService.showAuthorizeWithPassword()
                            } else {
                                return Observable.error(error)
                            }
                        })
                } else {
                    return LocalAuthenticationService.showAuthorizeWithPassword()
                }
            } else {
                return LocalAuthenticationService.showAuthorizeWithPassword()
                    .flatMap({ (isSuccess) -> Observable<Bool> in
                        guard isSuccess else { return Observable.just(isSuccess) }
                        let touchIDContext = LAContext()
                        return LocalAuthenticationUnit.canEvaluatePolicy(touchIDContext: touchIDContext)
                            .flatMap { LocalAuthenticationUnit.showIsEnableTouchIDOption() } // 询问是否打开 Touch ID
                            .flatMap({ (isEnabled) -> Observable<Bool> in
                                showTouchIDAuth(touchIDContext: touchIDContext)
                            })
                            .catchErrorJustReturn(false) // Touch ID 不可用时，返回 false
                            .do(onNext: { isOpen in
                                LocalStorage.isTouchIDOpened = isOpen // 保存用户选择信息
                            })
                            .map { _ in isSuccess } // 替换回密码认证结果
                    })
            }
        }

    }

    static func showAuthorizeWithReset() -> Driver<Bool> {
        return showAuthorize()
            .do(onError: { error in
                if let error = error as? AuthorizeError, error == AuthorizeError.needResetPassword {
                    // TODO: 展示重新设置密码页面
                }
            })
            .asDriver(onErrorJustReturn: false)
    }
}

extension UIApplication {

    static public func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
}
