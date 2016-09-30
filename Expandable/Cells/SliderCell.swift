//
//  SliderCell.swift
//  Expandable
//
//  Created by DianQK on 8/17/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SliderCell: UITableViewCell {

    @IBOutlet weak var slider: UISlider!

}
extension Reactive where Base: SliderCell {
    var value: ControlProperty<Int> {
        let observer = UIBindingObserver<UISlider, Int>(UIElement: base.slider) { (slider, value) in
            slider.value = Float(value)
        }.asObserver()
        return ControlProperty(values: base.slider.rx.value.map(Int.init), valueSink: observer)
    }
}
