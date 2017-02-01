//
//  CellButtonClickTableViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 04/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class InfoTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var detailButton: UIButton! {
        didSet {
            detailButton.layer.borderColor = UIColor.black.cgColor
            detailButton.layer.borderWidth = 1
            detailButton.layer.cornerRadius = 5
            detailButton.addTarget(self, action: #selector(_detailButtonTap), for: .touchUpInside)
        }
    }

    var detailButtonTap: (() -> ())?

    var title: String? {
        get {
            return titleLabel.text
        }
        set(title) {
            titleLabel.text = title
        }
    }

    var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private dynamic func _detailButtonTap() {
        detailButtonTap?()
    }

}

class CellButtonClickTableViewController: UITableViewController {

    struct Info {
        let name: String
        let url: URL
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil

        let infoItems = [
            Info(name: "Apple Developer", url: URL(string: "https://developer.apple.com/")!),
            Info(name: "GitHub", url: URL(string: "https://github.com")!),
            Info(name: "Dribbble", url: URL(string: "https://dribbble.com")!)
        ]

        Observable.just(infoItems)
            .bindTo(tableView.rx.items(cellIdentifier: "InfoTableViewCell", cellType: InfoTableViewCell.self)) { [unowned self] (row, element, cell) in
                cell.title = element.name
//                cell.detailButtonTap = {
//                    let safari = SFSafariViewController(url: element.url)
//                    safari.preferredControlTintColor = UIColor.black
//                    self.showDetailViewController(safari, sender: nil)
//                }
                cell.detailButton.rx.tap
                    .map { element.url }
                    .subscribe(onNext: { url in
                        print("Open :\(url)")
                        let safari = SFSafariViewController(url: element.url)
                        safari.preferredControlTintColor = UIColor.black
                        self.showDetailViewController(safari, sender: nil)
                        })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: rx.disposeBag)

    }

}
