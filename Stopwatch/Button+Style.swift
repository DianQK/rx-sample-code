//
//  Button+Style.swift
//  Stopwatch
//
//  Created by DianQK on 10/09/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct Style {
    struct Button {
        let title: String
        let titleColor: UIColor
        let isEnabled: Bool
        let backgroungImage: UIImage?
    }
}

extension Reactive where Base: UIButton {
    var style: AnyObserver<Style.Button> {
        return UIBindingObserver(UIElement: self.base, binding: { (button, style) in
            button.setTitle(style.title, for: .normal)
            button.setTitleColor(style.titleColor, for: .normal)
            button.isEnabled = style.isEnabled
            button.setBackgroundImage(style.backgroungImage, for: .normal)
        }).asObserver()
    }
}
