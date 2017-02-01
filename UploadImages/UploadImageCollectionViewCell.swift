
//
//  UploadImageCollectionViewCell.swift
//  UploadImageDemo
//
//  Created by DianQK on 05/01/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import RxSwift

class UploadImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var retryButton: UIButton!

    private(set) var reuseDisposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        progressView.progress = 0
        reuseDisposeBag = DisposeBag()
    }

}
