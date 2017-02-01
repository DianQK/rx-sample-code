//
//  ViewController.swift
//  TextInputDemo
//
//  Created by DianQK on 18/01/2017.
//  Copyright © 2017 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct InputModel {
    let inputText: Variable<String>
//    let isFirstResponder = Variable(false)
}

typealias InputSectionModel = SectionModel<String, InputModel>

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!

    let dataSource = RxCollectionViewSectionedReloadDataSource<InputSectionModel>()

    let inputText = Variable("")

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        inputText.asObservable()
            .bindTo(label.rx.text)
            .disposed(by: disposeBag)

        dataSource.configureCell = { dataSource, collectionView, indexPath, element in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputCollectionViewCell", for: indexPath) as! InputCollectionViewCell

            cell.textField.rx.controlEvent(.editingChanged)
                .map { cell.textField.text ?? "" }
                .filter { !$0.isEmpty }
                .subscribe(onNext: { text in
                    element.inputText.value += text
                })
                .disposed(by: cell.reuseDisposeBag)

            element.inputText.asObservable()
                .map({ (text) -> String in
                    if text.characters.count > indexPath.row {
                        return String(text.characters.map { $0 }[indexPath.row])
                    } else {
                        return ""
                    }
                })
                .bindTo(cell.textField.rx.text)
                .disposed(by: cell.reuseDisposeBag)

             cell.textField.rx.methodInvoked(#selector(UITextField.deleteBackward))
                .map { _ in }
                .subscribe(onNext: {
                    guard !element.inputText.value.isEmpty else { return }
                    let removedIndex = element.inputText.value.index(before: element.inputText.value.endIndex)
                    element.inputText.value.remove(at: removedIndex)
                })
                .disposed(by: cell.reuseDisposeBag)

            element.inputText.asObservable().map { $0.lengthOfBytes(using: String.Encoding.utf8) }
                .map { $0 == indexPath.row }
                .distinctUntilChanged()
                .bindTo(cell.isInputing)
                .disposed(by: cell.reuseDisposeBag)

            return cell
        }

        Observable.just([inputText, inputText, inputText, inputText, inputText, inputText])
            .map { $0.map { InputModel(inputText: $0) } }
            .map { [InputSectionModel(model: "", items: $0)] }
            .bindTo(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }

}
