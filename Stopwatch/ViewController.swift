//
//  ViewController.swift
//  Stopwatch
//
//  Created by DianQK on 9/8/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxExtensions

class ViewController: UIViewController {

    @IBOutlet private weak var displayTimeLabel: UILabel!
    @IBOutlet private weak var resetButton: UIButton!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var lapsTableView: UITableView!

    var type: StopwatchViewModelProtocol.Type = FinalViewModel.self

    let disposeBag = DisposeBag()

    private lazy var viewModel: StopwatchViewModelProtocol = self.type.init(input: (
        startAStopTrigger: self.startButton.rx.tap.asObservable(),
        resetALapTrigger: self.resetButton.rx.tap.asObservable())
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        do { // MARK: 展示时间
            viewModel.displayTime
                .bindTo(displayTimeLabel.rx.text)
                .disposed(by: rx.disposeBag)
        }

        viewModel.resetALapStyle
            .bindTo(resetButton.rx.style)
            .disposed(by: disposeBag)
        viewModel.startAStopStyle
            .bindTo(startButton.rx.style)
            .disposed(by: disposeBag)

        viewModel.displayElements
            .bindTo(lapsTableView.rx.items(cellIdentifier: "LapTableViewCell")) { index, element, cell in
                guard let detailTextLabel = cell.detailTextLabel else { return }
                element.displayTime.bindTo(detailTextLabel.rx.text).disposed(by: cell.rx.prepareForReuseBag)
                element.color.bindTo(detailTextLabel.rx.textColor).disposed(by: cell.rx.prepareForReuseBag)
            }
            .disposed(by: disposeBag)

    }

}
