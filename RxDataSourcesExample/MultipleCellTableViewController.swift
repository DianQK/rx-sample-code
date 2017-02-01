//
//  MultipleCellTableViewController.swift
//  RxDataSourcesExample
//
//  Created by DianQK on 05/10/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentImageView: UIImageView! {
        didSet {
            contentImageView.layer.masksToBounds = true
            contentImageView.layer.cornerRadius = 45
        }
    }

    var title: String? {
        get {
            return titleLabel.text
        }
        set(title) {
            titleLabel.text = title
        }
    }

    var contentImage: UIImage? {
        get {
            return contentImageView.image
        }
        set(image) {
            contentImageView.image = image
        }
    }

}

class DetailTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    var title: String? {
        get {
            return titleLabel.text
        }
        set(title) {
            titleLabel.text = title
        }
    }

    var detail: String? {
        get {
            return detailLabel.text
        }
        set(detail) {
            detailLabel.text = detail
        }
    }

}

enum Profile {
    case image(title: String, image: UIImage)
    case detail(title: String, detail: String)
}

private typealias ProfileSectionModel = SectionModel<String, Profile>

class MultipleCellTableViewController: UITableViewController {

    private let dataSource = RxTableViewSectionedReloadDataSource<ProfileSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            tableView.dataSource = nil
            tableView.delegate = nil
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 60
            tableView.contentInset = UIEdgeInsets(top: -25, left: 0, bottom: 0, right: 0)
        }

        do {
            dataSource.configureCell = { dataSource, tableView, indexPath, element in
                switch element {
                case let .image(title, image):
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.imageTableViewCell, for: indexPath)!
                    cell.title = title
                    cell.contentImage = image
                    return cell
                case let .detail(title, detail):
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.detailTableViewCell, for: indexPath)!
                    cell.title = title
                    cell.detail = detail
                    return cell
                }
            }
        }

        do {
            let profileSections = [
                ProfileSectionModel(model: "", items: [
                    Profile.image(title: "修改头像", image: UIImage(named: "DianQK")!),
                    Profile.detail(title: "修改昵称", detail: "靛青K")
                    ]),
                ProfileSectionModel(model: "", items: [
                    Profile.detail(title: "性别", detail: "男"),
                    Profile.detail(title: "生日", detail: "点击设置生日"),
                    Profile.detail(title: "星座", detail: "天秤座")
                    ]),
                ProfileSectionModel(model: "", items: [
                    Profile.detail(title: "签名", detail: "点击设置签名")
                    ]),
                ]

            Observable.just(profileSections)
                .bindTo(tableView.rx.items(dataSource: dataSource))
                .disposed(by: rx.disposeBag)
        }

    }

}
