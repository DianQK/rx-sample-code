//
//  StopwatchTypeListViewController.swift
//  Stopwatch
//
//  Created by DianQK on 12/09/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

typealias Action = () -> ()

class StopwatchTypeListViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    private struct Item {
        let title: String
        let type: StopwatchViewModelProtocol.Type
        init(title: String, type: StopwatchViewModelProtocol.Type) {
            self.title = title
            self.type = type
        }
    }
    
    @IBOutlet private weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = Observable.just([
            Item(title: "Basic", type: BasicViewModel.self),
            Item(title: "Timing", type: TimingViewModel.self),
            Item(title: "Final", type: FinalViewModel.self)
            ])
        
        items
            .bindTo(listTableView.rx.items(cellIdentifier: "ListTableViewCell")) { index, element, cell in
                cell.textLabel?.text = element.title
            }
            .disposed(by: disposeBag)

        listTableView.rx.itemSelected.map { (at: $0, animated: true) }
            .subscribe(onNext: listTableView.deselectRow)
            .disposed(by: disposeBag)
        
        listTableView.rx.modelSelected(Item.self)
            .subscribe(onNext: { [unowned self] item in
                let stopwatchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
                stopwatchViewController.type = item.type
                self.show(stopwatchViewController, sender: nil)
                })
            .disposed(by: disposeBag)

    }
}
