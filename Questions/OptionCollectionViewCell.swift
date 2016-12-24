//
//  OptionCollectionViewCell.swift
//  Questions
//
//  Created by DianQK on 10/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class OptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var displayImageView: UIImageView!

    var isDisabled: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.contentView.alpha = self.isDisabled ? 0.5 : 1
            }
        }
    }
    
}
