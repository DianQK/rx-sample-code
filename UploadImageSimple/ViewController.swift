//
//  ViewController.swift
//  UploadImageSimple
//
//  Created by DianQK on 24/03/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import MBProgressHUD
import RxSwift
import RxCocoa

extension Reactive where Base: MBProgressHUD {

    var isProgressing: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base, binding: { (hud, isProgressing) in
            if isProgressing {
                hud.show(animated: true)
            } else {
                hud.hide(animated: true)
            }
        })
    }

}

extension Reactive where Base: UIView {

    var message: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base, binding: { (view, message) in
            if !message.isEmpty {
                view.showMessage(message)
            }
        })
    }

}

extension UIView {

    func showMessage(_ message: String) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.mode = .text
        hud.label.text = message
        hud.hide(animated: true, afterDelay: 1.5)
    }

}

extension ObservableConvertibleType {

    func asDriverJustCompleted(showMessageView messageView: UIView) -> Driver<E> {
        return self.asObservable()
            .asDriver { (error) -> Driver<E> in
                messageView.showMessage(error.localizedDescription)
                return Driver.empty()
        }
    }

}

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let uploadActivityIndicator = ActivityIndicator()

        let hud = MBProgressHUD(view: self.view)
        self.view.addSubview(hud)
        hud.label.text = "上传中"
        hud.button.setTitle("取消", for: .normal)

        let view: UIView = self.view

        let cancel = hud.button.rx.tap.asObservable()

        cancel // workaround
            .map { "你取消了上传操作" }
            .bindTo(self.view.rx.message)
            .disposed(by: disposeBag)

        uploadActivityIndicator.asDriver()
            .debug()
            .drive(hud.rx.isProgressing)
            .disposed(by: disposeBag)

//        flatMapFirst { (images) -> Driver<[Any]> in
//            let imageCount = images.count
//            var count = 0
//            hud.detailsLabel.text = "(\(count)/\(imageCount))"
//            let uploadedImage = images
//                .map { URLSession.shared.rx.json(url: URL(string: "https://httpbin.org/get?image=\($0)")!)
//                    .observeOn(MainScheduler.instance)
//                    .do(onNext: { _ in
//                        count += 1
//                        hud.detailsLabel.text = "(\(count)/\(imageCount))"
//                    })
//            }
//            return Observable.combineLatest(uploadedImage)
//                .observeOn(MainScheduler.instance)
//                .takeUntil(cancel) // toArray 后面
//                .trackActivity(uploadActivityIndicator)
//                .asDriverJustCompleted(showMessageView: view)
//        }



//            .flatMapFirst { (images) -> Driver<(completedCount: Int, totalCount: Int)> in
//                let imageCount = images.count
//                let uploadedImage = images.map { URLSession.shared.rx.json(url: URL(string: "https://httpbin.org/get?image=\($0)")!) }
//                return Observable.concat(uploadedImage)
//                    .mapWithIndex({ (result, index) -> (result: Any, index: Int) in
//                        return (result: result, index: index)
//                    })
//                    .observeOn(MainScheduler.instance)
//                    .do(onNext: { (_, index) in
//                        hud.detailsLabel.text = "(\(index + 1)/\(imageCount))"
//                    }, onSubscribe: {
//                        hud.detailsLabel.text = "(\(0)/\(imageCount))"
//                    })
//                    .map { $0.0 }
//                    .takeUntil(cancel) // toArray 后面
//                    .toArray()
//                    .map({ (uploadedImages) -> (completedCount: Int, totalCount: Int) in
//                        return (completedCount: uploadedImages.count, totalCount: imageCount)
//                    })
//                    .trackActivity(uploadActivityIndicator)
//                    .asDriverJustCompleted(showMessageView: view)
//            }
//            .map { (completedCount: Int, totalCount: Int) -> String in
//                if completedCount < totalCount {
//                    return "上传 \(totalCount) 张，完成 \(completedCount) 张"
//                } else {
//                    return "全部上传成功"
//                }
//        }

        button.rx.tap.asDriver()
            .map { (1...9) }
            .flatMapFirst { (images) -> Driver<(completedCount: Int, totalCount: Int)> in
                let imageCount = images.count
                let uploadedImage = images.map { URLSession.shared.rx.json(url: URL(string: "https://httpbin.org/get?image=\($0)")!) }
                return Observable.concat(uploadedImage)
                    .mapWithIndex({ (result, index) -> (result: Any, index: Int) in
                        return (result: result, index: index)
                    })
                    .observeOn(MainScheduler.instance)
                    .do(onNext: { (_, index) in
                        hud.detailsLabel.text = "(\(index + 1)/\(imageCount))"
                    }, onSubscribe: {
                        hud.detailsLabel.text = "(\(0)/\(imageCount))"
                    })
                    .map { $0.0 }
                    .takeUntil(cancel)
                    .toArray()
                    .map({ (uploadedImages) -> (completedCount: Int, totalCount: Int) in
                        return (completedCount: uploadedImages.count, totalCount: imageCount)
                    })
                    .trackActivity(uploadActivityIndicator)
                    .asDriverJustCompleted(showMessageView: view)
            }
            .map { (completedCount: Int, totalCount: Int) -> String in
                if completedCount < totalCount {
                    return "上传 \(totalCount) 张，完成 \(completedCount) 张"
                } else {
                    return "全部上传成功"
                }
            }
            .drive(self.view.rx.message)
            .disposed(by: disposeBag)

    }

}

