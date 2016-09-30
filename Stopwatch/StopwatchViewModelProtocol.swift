//
//  StopwatchViewModelProtocol.swift
//  Stopwatch
//
//  Created by DianQK on 12/09/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift

protocol StopwatchViewModelProtocol {
    var startAStopStyle: Observable<Style.Button> { get }
    var resetALapStyle: Observable<Style.Button> { get }
    var displayTime: Observable<String> { get }
    var displayElements: Observable<[(title: Observable<String>, displayTime: Observable<String>, color: Observable<UIColor>)]> { get }
    
    init(input: (startAStopTrigger: Observable<Void>, resetALapTrigger: Observable<Void>))
}
