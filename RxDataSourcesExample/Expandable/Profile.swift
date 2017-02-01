//
//  Profile.swift
//  Expandable
//
//  Created by DianQK on 8/17/16.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxExtensions

struct ProfileItem: IDHashable, IdentifiableType {

    private let disposeBag = DisposeBag()

    enum Display {
        case fullname//(first: Variable<String>, last: Variable<String>)
        case dateOfBirth//(Variable<Date>)
        case maritalStatus//(isMarried: Variable<Bool>)
        case favoriteSport//(Variable<String>)
        case favoriteColor//(Variable<String>)
        case level//(Variable<Int>)

        var subTitle: String {
            switch self {
            case .fullname: return "Fullname"
            case .dateOfBirth: return "Date of Birth"
            case .maritalStatus: return "Marital Status"
            case .favoriteSport: return "Favorite Sport"
            case .favoriteColor: return "Favorite Color"
            case .level: return "Level"
            }
        }
    }

    enum Input {
        case textField(text: Variable<String>, placeholder: String)
        case datePick(Variable<Date>)
        case status(title: String, isOn: Variable<Bool>)
        case title(String, favorite: Variable<String>)
        case level(Variable<Int>)
    }

    enum `Type` {
        case display(title: Variable<String>, type: Display, isExpanded: Variable<Bool>)
        case input(Input)
    }

    let type: Type
    let id: String
    let subItems: Observable<[ProfileItem]>

    var allItems: Observable<[ProfileItem]> {
        return Observable.combineLatest(Observable.just([self]), self.subItems, resultSelector: +)
    }

    init(defaultTitle title: String, displayType: Display) {
        self.init(type: Type.display(title: Variable(title), type: displayType, isExpanded: Variable(false)))
    }

    private init(type: Type) {
        self.type = type
        switch type {
        case let .display(title, type, isExpanded):
            let subItems: [ProfileItem]
            switch type {
            case .fullname:
                let fullname = title.value.components(separatedBy: " ").safe
                let firstName = Variable(fullname[0] ?? "")
                let lastName = Variable(fullname[1] ?? "")

let firstSubItem = ProfileItem(type: .input(.textField(text: firstName, placeholder: "Firstname")))
let lastSubItem = ProfileItem(type: .input(.textField(text: lastName, placeholder: "Lastname")))
subItems = [firstSubItem, lastSubItem]

Observable
    .combineLatest(
        firstName.asObservable(),
        lastName.asObservable()
    ) { $0 + " " + $1 }
    .bindTo(title)
    .disposed(by: disposeBag)
                id = "fullname"
            case .dateOfBirth:
                let date = Variable(Date())
                let subItem = ProfileItem(type: .input(.datePick(date)))
                subItems = [subItem]
date.asObservable()
    .map(DateFormatter().config.longStyle.string)
    .bindTo(title)
                    .disposed(by: disposeBag)
                id = "dateOfBirth"
            case .maritalStatus:
                let isMarried = Variable(true)
                let subItem = ProfileItem(type: .input(.status(title: "Off = Single, On = Married", isOn: isMarried)))
                subItems = [subItem]
isMarried.asObservable()
    .skip(1)
    .map { $0 ? "Married" : "Single" }
    .bindTo(title)
                    .disposed(by: disposeBag)
                id = "maritalStatus"
            case .favoriteColor:
                let red = ProfileItem(type: .input(.title("Red", favorite: title)))
                let green = ProfileItem(type: .input(.title("Green", favorite: title)))
                let blue = ProfileItem(type: .input(.title("Blue", favorite: title)))
                subItems = [red, green, blue]
                id = "favoriteColor"
            case .favoriteSport:
                let football = ProfileItem(type: .input(.title("Football", favorite: title)))
                let basketball = ProfileItem(type: .input(.title("Basketball", favorite: title)))
                let baseball = ProfileItem(type: .input(.title("Baseball", favorite: title)))
                let volleyball = ProfileItem(type: .input(.title("Volleyball", favorite: title)))
                subItems = [football, basketball, baseball, volleyball]
                id = "favoriteSport"
            case .level:
                let level = Variable(0)
                let subItem = ProfileItem(type: .input(.level(level)))
                subItems = [subItem]
                level.asObservable()
                    .map(String.init)
                    .bindTo(title)
                    .disposed(by: disposeBag)
                id = "level"
            }
            do { // 选择好后，直接收起子项目
                switch type {
                case .favoriteColor, .favoriteSport:
                    title.asObservable().skip(1)
//                        .distinctUntilChanged()
                        .subscribe(onNext: { _ in
                            isExpanded.value = !isExpanded.value
                        })
                        .disposed(by: disposeBag)
                default: break
                }
            }
            self.subItems = isExpanded.asObservable()
                .map { $0 ? subItems : [] }
                .shareReplay(1)
        case let .input(input):
            switch input {
            case let .datePick(date):
                id = "datePick\(date.value)"
            case let .level(level):
                id = "level\(level.value)"
            case let .status(title, _):
                id = "status\(title)"
            case let .textField(_, placeholder):
                id = "textField\(placeholder)"
            case let .title(title, _):
                id = "title\(title)"
            }
            self.subItems = Observable.just([]).shareReplay(1)
        }
    }

    var hashValue: Int {
        return id.hashValue
    }

    var identity: String {
        return id
    }

}

enum ProfileSectionType: String, IdentifiableType {
    case personal = "Personal"
    case preferences = "Preferences"
    case workExperience = "Work Experience"

    var identity: String {
        return rawValue
    }
}
