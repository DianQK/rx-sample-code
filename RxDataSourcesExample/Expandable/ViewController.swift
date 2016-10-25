//
//  ViewController.swift
//  Expandable
//
//  Created by DianQK on 8/17/16.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

infix operator => : DefaultPrecedence

public func =><T : Equatable>(lhs: RxSwift.Variable<T>, rhs: RxSwift.Variable<T>) -> Disposable {
    return lhs.asObservable().bindTo(rhs)
}

public func =><T>(property: RxCocoa.ControlProperty<T>, variable: RxSwift.Variable<T>) -> Disposable {
    return property.bindTo(variable)
}

public func =><O : ObserverType, E>(variable: RxSwift.Variable<E>, observer: O) -> Disposable where O.E == Optional<E> {
    return variable.asObservable().bindTo(observer)
}

public func =><O : ObserverType, E, OB: ObservableType>(observable: OB, observer: O) -> Disposable where O.E == Optional<E>, OB.E == E {
    return observable.asObservable().bindTo(observer)
}

public func =><T>(property: RxCocoa.ControlProperty<T>, variable: RxSwift.Variable<T?>) -> Disposable {
    return property.map(Optional.init).bindTo(variable)
//    return property.bindTo(variable)
}

public func =><T>(variable: RxSwift.Variable<T>, property: RxCocoa.ControlProperty<T>) -> Disposable {
    return variable.asObservable().bindTo(property)
}

private typealias ProfileSectionModel = AnimatableSectionModel<ProfileSectionType, ProfileItem>

class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private let dataSource = RxTableViewSectionedAnimatedDataSource<ProfileSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let fullname = ProfileItem(defaultTitle: "Xutao Song", displayType: .fullname)
            let dateOfBirth = ProfileItem(defaultTitle: "2016年9月30日", displayType: .dateOfBirth)
            let maritalStatus = ProfileItem(defaultTitle: "Married", displayType: .maritalStatus)

            let favoriteSport = ProfileItem(defaultTitle: "Football", displayType: .favoriteSport)
            let favoriteColor = ProfileItem(defaultTitle: "Red", displayType: .favoriteColor)

            let level = ProfileItem(defaultTitle: "3", displayType: .level)

            let firstSectionItems = Observable.combineLatest(fullname.allItems, dateOfBirth.allItems, maritalStatus.allItems) { $0 + $1 + $2 }

            let secondSectionItems = Observable.combineLatest(favoriteSport.allItems, favoriteColor.allItems, resultSelector: +)

            let thirdSectionItems = level.allItems

            let firstSection = firstSectionItems.map { ProfileSectionModel(model: .personal, items: $0) }
            let secondSection = secondSectionItems.map { ProfileSectionModel(model: .preferences, items: $0) }
            let thirdSection = thirdSectionItems.map { ProfileSectionModel(model: .workExperience, items: $0) }

            Observable.combineLatest(firstSection, secondSection, thirdSection) { [$0, $1, $2] }
                .bindTo(tableView.rx.items(dataSource: dataSource))
                .addDisposableTo(rx.disposeBag)
        }

        do {
            tableView.estimatedRowHeight = 44
            tableView.rowHeight = UITableViewAutomaticDimension
        }

        do {
            dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .fade)

            dataSource.configureCell = { dataSource, tableView, indexPath, item in
                switch item.type {
                case let .display(title, type, _):
                    let infoCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.normalCell, for: indexPath)!
                    infoCell.detailTextLabel?.text = type.subTitle
                    if let textLabel = infoCell.textLabel {
                        (title => textLabel.rx.text).addDisposableTo(infoCell.rx.prepareForReuseBag)
                    }
                    return infoCell
                case let .input(input):
                    switch input {
                    case let .datePick(date):
                        let datePickerCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.datePickerCell, for: indexPath)!
                        (datePickerCell.rx.date <-> date).addDisposableTo(datePickerCell.rx.prepareForReuseBag)
                        return datePickerCell
                    case let .level(level):
                        let sliderCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sliderCell, for: indexPath)!
                        (sliderCell.rx.value <-> level).addDisposableTo(sliderCell.rx.prepareForReuseBag)
                        return sliderCell
                    case let .status(title, isOn):
                        let switchCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.switchCell, for: indexPath)!
                        switchCell.title = title
                        (switchCell.rx.isOn <-> isOn).addDisposableTo(switchCell.rx.prepareForReuseBag)
                        return switchCell
case let .textField(text, placeholder):
    let textFieldCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.textFieldCell, for: indexPath)!
    textFieldCell.placeholder = placeholder
    (textFieldCell.rx.text <-> text).addDisposableTo(textFieldCell.rx.prepareForReuseBag)
    return textFieldCell
                    case let .title(title, _):
                        let titleCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.normalItemCell, for: indexPath)!
                        titleCell.textLabel?.text = title
                        return titleCell
                    }
                }
            }

            dataSource.titleForHeaderInSection = { dataSource, section in
                return dataSource[section].model.rawValue
            }
        }

        do {
            tableView.rx.modelSelected(ProfileItem.self)
                .subscribe(onNext: { item in
                    switch item.type {
                    case let .display(_, _, isExpanded):
                        isExpanded.value = !isExpanded.value
                    case let .input(input):
                        switch input {
                        case let .title(title, favorite):
                            favorite.value = title
                        default:
                            break
                        }
                    }
                })
                .addDisposableTo(rx.disposeBag)

            tableView.rx.enableAutoDeselect()
                .addDisposableTo(rx.disposeBag)
        }

    }

}
