//
//  CustomRefreshViewController.swift
//  CustomRefresh
//
//  Created by wc on 24/12/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

class CustomRefreshViewController: UIViewController {
    
    @IBOutlet private weak var refreshBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var refreshWithAnimatedBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataSource = RxTableViewSectionedAnimatedOrReloadDataSource<NumberSection>()
        
        dataSource.configureCell = { dataSource, tableView, indexPath, element in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "\(element.number)"
            return cell
        }
        
        let initialRandomizedSections = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: initialValue())
        
        Observable.from([
            refreshBarButtonItem.rx.tap.asObservable().startWith(()).replace(with: true),
            refreshWithAnimatedBarButtonItem.rx.tap.asObservable().replace(with: false)
            ])
            .merge()
            .scan((randomizer: initialRandomizedSections, isRefresh: true)) { a, isRefresh in
                return (randomizer: a.randomizer.randomize(), isRefresh: isRefresh)
            }
            .map { a in
                return RefreshSectionList(sectionModels: a.randomizer.sections, isRefresh: a.isRefresh)
            }
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    
    }
    
    func initialValue() -> [NumberSection] {
        let nSections = 10
        let nItems = 2
        
        return (0 ..< nSections).map { (i: Int) in
            NumberSection(header: "Section \(i + 1)", numbers: $(Array(i * nItems ..< (i + 1) * nItems)), updated: Date())
        }
    }

}

func $(_ numbers: [Int]) -> [IntItem] {
    return numbers.map { IntItem(number: $0, date: Date()) }
}
