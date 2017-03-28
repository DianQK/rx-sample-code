//
//  UploadImageViewController.swift
//  UploadImageDemo
//
//  Created by DianQK on 05/01/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import QBImagePicker
import Photos
import RxSwift
import RxCocoa
import Alamofire

struct UploadImageModel {
    let asset: PHAsset
    let progress: Observable<Double>
    let displayImage: UIImage
    let retry: AnyObserver<()>
    let error: Observable<Swift.Error>
}

class UploadImageViewController: UIViewController {
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var collectionView: UICollectionView!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        addBarButtonItem.rx.tap.asObservable()
            .flatMap { [unowned self] () -> Observable<[PHAsset]> in
                let imagePickerController = QBImagePickerController()
                imagePickerController.mediaType = .image
                imagePickerController.allowsMultipleSelection = true
                imagePickerController.showsNumberOfSelectedAssets = true
                self.showDetailViewController(imagePickerController, sender: nil)
                return imagePickerController.rx.didFinishPickingAssets
                    .observeOn(SerialDispatchQueueScheduler.init(qos: DispatchQoS.background))
            }
            .flatMap { assets -> Observable<[UploadImageModel]> in
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = false
                let uploadImageModels = assets
                    .map { (asset) -> Observable<UploadImageModel> in

                    let image = manager.rx
                        .requestImage(for: asset, targetSize: CGSize(width: 400, height: 400), contentMode: .aspectFit, options: option)
                        .map { $0.0 }

                    let retry = PublishSubject<()>()

                    let errorSubject = PublishSubject<Swift.Error>()

                    let progress = manager.rx
                        .requestImageData(for: asset, options: option)
                        .map { $0.0 }
                        .flatMap { data -> Observable<Double> in
                            return Observable.create({ (observer) -> Disposable in
                                let task = Alamofire.upload(data, to: "https://httpbin.org/post")
                                    .uploadProgress { progress in // main queue by default
//                                        print("Upload Progress: \(progress.fractionCompleted)")
                                        observer.onNext(progress.fractionCompleted)
                                        if progress.fractionCompleted == 1 {
                                            print("Completed")
                                            observer.onNext(1) // workaround
                                            observer.onCompleted()
                                        }
                                        progress.cancellationHandler = {
                                            print("Cancel")
                                        }
                                    }
                                    .response(completionHandler: { result in
                                        if let error = result.error {
                                            observer.onError(error)
                                        }
                                    })

                                return Disposables.create {
                                    task.cancel()
                                }
                            })
                            .debug()
                            .retryWhen({ (errorObservable) in
                                errorObservable
                                    .do(onNext: { error in
                                        errorSubject.onNext(error)
                                    })
                                    .flatMap { error in
                                        retry.asObservable().take(1)
                                }
                            })
                    }
                    return image.flatMap { image -> Observable<UploadImageModel> in
                        return Observable.create({ (observer) -> Disposable in
                            let progress = progress.debug().replay(1)
                            observer.onNext(UploadImageModel(asset: asset, progress: progress, displayImage: image, retry: retry.asObserver(), error: errorSubject.asObservable()))
                            observer.onCompleted()
                            return progress.connect()
                        })
                    }
                }

                return Observable.concat(uploadImageModels).toArray()
            }
            .bindTo(collectionView.rx.items(cellIdentifier: "UploadImageCollectionViewCell", cellType: UploadImageCollectionViewCell.self)) { row, uploadImageModel, cell in
                cell.imageView.image = uploadImageModel.displayImage
                uploadImageModel.progress
                    .map { Float($0) }
                    .bindTo(cell.progressView.rx.progress)
                    .disposed(by: cell.reuseDisposeBag)

                uploadImageModel.error.map { _ in false }
                    .startWith(true)
                    .bindTo(cell.retryButton.rx.isHidden)
                    .disposed(by: cell.reuseDisposeBag)

                cell.retryButton.rx.tap.asObservable()
                    .do(onNext: {
                        cell.retryButton.isHidden = true
                    })
                    .bindTo(uploadImageModel.retry)
                    .disposed(by: cell.reuseDisposeBag)
            }
            .disposed(by: disposeBag)

    }

}
