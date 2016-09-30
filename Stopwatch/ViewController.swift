//
//  ViewController.swift
//  Stopwatch
//
//  Created by DianQK on 9/8/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var displayTimeLabel: UILabel!
    @IBOutlet private weak var resetButton: UIButton!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var lapsTableView: UITableView!
    
    var type: StopwatchViewModelProtocol.Type = FinalViewModel.self

    private lazy var viewModel: StopwatchViewModelProtocol = self.type.init(input: (
        startAStopTrigger: self.startButton.rx.tap.asObservable(),
        resetALapTrigger: self.resetButton.rx.tap.asObservable())
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.displayTime.bindTo(displayTimeLabel.rx.text).addDisposableTo(rx.disposeBag)
        viewModel.resetALapStyle.bindTo(resetButton.rx.style).addDisposableTo(rx.disposeBag)
        viewModel.startAStopStyle.bindTo(startButton.rx.style).addDisposableTo(rx.disposeBag)
        viewModel.displayElements
            .bindTo(lapsTableView.rx.items(cellIdentifier: "LapTableViewCell")) { index, element, cell in
                element.displayTime.bindTo(cell.detailTextLabel?.rx.text)?.addDisposableTo(cell.rx.prepareForReuseBag)
                element.color.bindTo(cell.detailTextLabel?.rx.textColor)?.addDisposableTo(cell.rx.prepareForReuseBag)
                element.title.bindTo(cell.textLabel?.rx.text)?.addDisposableTo(cell.rx.prepareForReuseBag)
            }
            .addDisposableTo(rx.disposeBag)

    }

}



