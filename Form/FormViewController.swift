//
//  FormViewController.swift
//  Form
//
//  Created by DianQK on 14/03/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum FormType {
    case avatar(title: String, image: Variable<UIImage?>)
    case name(title: String, input: Variable<String>)
    case phoneNumber(title: String, input: Variable<String>)
    case birthday(title: String, birthday: Driver<Date>)
    case date(date: Variable<Date?>)
    case constellation(title: String, constellation: Driver<Constellation?>)
}

class FormViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let avatarImage = Variable<UIImage?>(nil)
        let name = Variable<String>("")
        let phoneNumber = Variable<String>("")
        let birthday = Variable<Date?>(nil)
        let constellation = Variable<Constellation?>(nil)

        



    }

}

