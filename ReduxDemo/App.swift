//
//  App.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxExtensions

@UIApplicationMain
class App: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        _state.item.modifyItem
            .asObservable()
            .skip(1)
            .subscribe(onNext: { item in
                if let _ = item {
                    // =.= 如果有修改项目，跳到修改项目页
                    topViewController()?.show(R.storyboard.collection.editComponent()!, sender: nil)
                } else {
                    // 如果删除了修改项目，则返回到之前页面
                    guard let top = topViewController() else { return }
                    top.view.endEditing(true)
                    dismissViewController(top, animated: true)
                }
            })
            .addDisposableTo(disposeBag)

        return true
    }

}
