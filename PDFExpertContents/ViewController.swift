//
//  ViewController.swift
//  PDF-Expert-Contents
//
//  Created by DianQK on 17/09/2016.
//  Copyright © 2016 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwiftyJSON
import SafariServices

private typealias ContentsSectionModel = AnimatableSectionModel<String, ExpandableContentItemModel>

class ViewController: UIViewController {

    @IBOutlet private weak var contentsTableView: UITableView!

    private let dataSource = RxTableViewSectionedAnimatedDataSource<ContentsSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetch = Observable
            .just(R.file.contentsJson, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .shareReplay(1)

        let expandableItems = fetch
            .map { try! Data(resource: $0) }
            .map { JSON(data: $0) }
            .map { json -> [ExpandableContentItemModel] in
                json.arrayValue.map {
                    ContentItemModel.createExpandableContentItemModel(json: $0, withPreLevel: -1)
                }
            }
            .share()

        let result = expandableItems
            .map { (items: [ExpandableContentItemModel]) in
                items.map { item in
                    Observable.combineLatest(Observable.just([item]), item.subItems, resultSelector: +)
                }
            }
            .flatMap { (items: [Observable<[ExpandableContentItemModel]>]) -> Observable<[ExpandableContentItemModel]> in
                guard let first = items.first else { return Observable.empty() }
                return items.dropFirst().reduce(first) { acc, x in
                    Observable.combineLatest(acc, x, resultSelector: +)
                }
            }
            .map { [ContentsSectionModel(model: "", items: $0)] }
            .shareReplay(1)

        result
            .observeOn(MainScheduler.instance)
            .bindTo(contentsTableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        do {
            contentsTableView.rowHeight = UITableViewAutomaticDimension
            contentsTableView.estimatedRowHeight = 48
        }

        do {
            dataSource.animationConfiguration = RxDataSources.AnimationConfiguration(
                insertAnimation: .automatic,
                reloadAnimation: .automatic,
                deleteAnimation: .automatic)

            dataSource.configureCell = { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expandedCell, for: indexPath)!

                let headIndent = CGFloat(item.model.level * 15)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.firstLineHeadIndent = headIndent
                paragraphStyle.headIndent = headIndent
                let font = item.canExpanded ? UIFont.boldSystemFont(ofSize: 17) : UIFont.systemFont(ofSize: 17)
                let attributeString = NSAttributedString(string: item.model.title, attributes: [
                    NSParagraphStyleAttributeName: paragraphStyle,
                    NSFontAttributeName: font
                    ])

                cell.attributedText = attributeString
                cell.canExpanded = item.canExpanded
                cell.level = item.model.level
                if item.canExpanded {
                    item.isExpanded.asObservable()
                        .bindTo(cell.rx.isExpanded)
                        .disposed(by: cell.prepareForReuseBag)
                }
                return cell
            }
        }

        do {
            contentsTableView.rx.modelSelected(ExpandableContentItemModel.self)
                .subscribe(onNext: { [unowned self] item in
                    if item.canExpanded {
                        item.isExpanded.value = !item.isExpanded.value
                    } else if let url = item.model.url {
                        let sf = SFSafariViewController(url: url)
                        sf.preferredControlTintColor = UIColor.black
                        self.present(sf, animated: true, completion: nil)
                    }
                })
                .disposed(by: rx.disposeBag)

            contentsTableView.rx.itemSelected.map { (at: $0, animated: true) }
                .subscribe(onNext: contentsTableView.deselectRow)
                .disposed(by: rx.disposeBag)
        }

    }

}
