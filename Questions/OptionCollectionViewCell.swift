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
import RxExtensions

class OptionCollectionViewCell: ReactiveCollectionViewCell {

    @IBOutlet weak var displayImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.alpha = 1
    }
    
}

extension Reactive where Base: OptionCollectionViewCell {
    
    var isSelected: UIBindingObserver<OptionCollectionViewCell, Bool> {
        return UIBindingObserver<OptionCollectionViewCell, Bool>(UIElement: self.base) { cell, isSelected in
            cell.contentView.alpha = isSelected ? 1 : 0.5
        }
    }
    
}
