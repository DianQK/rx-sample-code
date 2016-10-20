//
//  VideoCollectionViewCell.swift
//  VideoCell
//
//  Created by DianQK on 19/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import RxExtensions

open class ReactiveCollectionViewCell: UICollectionViewCell {

    public private(set) var prepareForReuseBag = DisposeBag()

    open override func prepareForReuse() {
        super.prepareForReuse()
        prepareForReuseBag = DisposeBag()
    }
}

class VideoCollectionViewCell: ReactiveCollectionViewCell {

    static let itemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)

    private let playControlSubject = Variable(false)

    lazy var player: AVPlayer = {
        let player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(origin: CGPoint.zero, size: VideoCollectionViewCell.itemSize)
        self.contentView.layer.addSublayer(playerLayer)
        return player
    }()

    let playerItem = ReplaySubject<AVPlayerItem>.create(bufferSize: 1)

    private let disposeBag = DisposeBag()

    func play() {
        playControlSubject.value = true
    }

    func pause() {
        playControlSubject.value = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        Observable.combineLatest(playerItem.asObservable()
            .do(onNext: { [weak self] playerItem in
                guard let `self` = self else { return }
                self.player.pause()
                self.player.replaceCurrentItem(with: playerItem)
                }), playControlSubject.asObservable().distinctUntilChanged()) { (player: $0, play: $1) }
            .subscribe(onNext: { [weak self] player, play in
                switch play {
                case true:
                    self?.player.play()
                case false:
                    self?.player.pause()
                }
            })
            .addDisposableTo(disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


