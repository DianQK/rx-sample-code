//
//  ViewController.swift
//  VideoCell
//
//  Created by DianQK on 19/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import SnapKit
import Alamofire

struct PlayItem {
    let url: NSURL
    let currentTime: Variable<CGFloat>
}

class ViewController: UIViewController {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = VideoCollectionViewCell.itemSize
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 15
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return collectionView
    }()

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        func getVideo(forURL url: URL) -> ConnectableObservable<AVPlayerItem> {
            return Observable.create({ (observer) -> Disposable in

                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

                let filePath = documentsURL.appendingPathComponent(url.lastPathComponent)
                print(filePath)

                if let isExist = try? filePath.checkResourceIsReachable(), isExist {
                    //                    observer.onNext(AVURLAsset(URL: filePath))
                    print("文件存在")
                    observer.onNext(AVPlayerItem(url: filePath))
                    observer.onCompleted()
                } else {
                    download(url, method: .get, to: { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                        return (destinationURL: filePath, options: DownloadRequest.DownloadOptions.removePreviousFile)
                    }).response(completionHandler: { (respone) in
                        print(respone)
                        observer.onNext(AVPlayerItem(url: filePath))
                        observer.onCompleted()
                    })
                }

                return Disposables.create()
            }).replay(1)

        }

        collectionView.backgroundColor = UIColor.white
        collectionView.rx.setDelegate(self).addDisposableTo(disposeBag)

        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")

        let videos = Observable.just([
            URL(string: "http://scontent.cdninstagram.com/t50.2886-16/14692787_108731326264471_3115559333669109760_n.mp4")!,
            URL(string: "http://scontent.cdninstagram.com/t50.2886-16/14661865_1670346503204509_3322833050919763968_n.mp4")!,
            URL(string: "http://scontent.cdninstagram.com/t50.2886-16/14655975_1187479824661418_3370087234593095680_n.mp4")!,
            URL(string: "http://scontent.cdninstagram.com/t50.2886-16/14692787_108731326264471_3115559333669109760_n.mp4")!,
            URL(string: "http://scontent.cdninstagram.com/t50.2886-16/14661865_1670346503204509_3322833050919763968_n.mp4")!,
            URL(string: "http://scontent.cdninstagram.com/t50.2886-16/14655975_1187479824661418_3370087234593095680_n.mp4")!
            ])
            .map { $0.map(getVideo) }
            .shareReplay(1)

        videos
            .map { Disposables.create($0.map { $0.connect() }) }
            .subscribe(onNext: { [unowned self] (cancel) in
                cancel.addDisposableTo(self.rx.disposeBag)
                })
            .addDisposableTo(self.rx.disposeBag)

        videos
            .bindTo(collectionView.rx.items(cellIdentifier: "Cell", cellType: VideoCollectionViewCell.self)) { index, element, cell in
                element.bindTo(cell.playerItem).addDisposableTo(cell.prepareForReuseBag)
            }
            .addDisposableTo(rx.disposeBag)

    }

}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! VideoCollectionViewCell).play()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! VideoCollectionViewCell).pause()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.visibleCells.flatMap { $0 as? VideoCollectionViewCell }.forEach { $0.pause() }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.visibleCells.flatMap { $0 as? VideoCollectionViewCell }.forEach { $0.play() }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        collectionView.visibleCells.flatMap { $0 as? VideoCollectionViewCell }.forEach { $0.play() }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        collectionView.visibleCells.flatMap { $0 as? VideoCollectionViewCell }.forEach { $0.play() }
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        collectionView.visibleCells.flatMap { $0 as? VideoCollectionViewCell }.forEach { $0.play() }
    }
}

