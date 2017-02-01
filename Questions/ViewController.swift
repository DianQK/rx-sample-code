//
//  ViewController.swift
//  Questions
//
//  Created by DianQK on 10/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

struct Option: IdentifiableType, Hashable {
    let id: Int
    let image: UIImage
    let isSelected = Variable<Bool?>(nil)
    
    var identity: Int {
        return id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
    
    static func ==(lhs: Option, rhs: Option) -> Bool {
        switch (lhs.isSelected.value, rhs.isSelected.value) {
        case (let .some(lhsIsSelected), let .some(rhsIsSelected)) where lhsIsSelected == rhsIsSelected :
            return lhs.id == rhs.id && lhs.image == rhs.image
        case (.none, .none):
            return lhs.id == rhs.id && lhs.image == rhs.image
        default:
            return false
        }
    }
    
    
}

typealias QuestionSectionModel = AnimatableSectionModel<String, Option>

class ViewController: UIViewController {

    @IBOutlet private weak var questionsCollectionView: UICollectionView! {
        didSet {
            questionsCollectionView.allowsSelection = true
            questionsCollectionView.allowsMultipleSelection = true
        }
    }
    
    @IBOutlet private weak var doneBarButtonItem: UIBarButtonItem!

    private let questions: Variable<[QuestionSectionModel]> = Variable([])

    fileprivate let dataSource = RxCollectionViewSectionedAnimatedCompletedDataSource<QuestionSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        questions.value = defaultQuestions

        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)

        dataSource.configureCell = { dataSource, collectionView, indexPath, element in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.optionCollectionViewCell, for: indexPath)!
            cell.displayImageView.image = element.image
            element.isSelected.asObservable().filterNil()
                .bindTo(cell.rx.isSelected)
                .disposed(by: cell.prepareForReuseBag)
            return cell
        }

        dataSource.performBatchUpdatesCompletion = {
            self.questionsCollectionView.scrollToItem(at: IndexPath(row: 0, section: self.questions.value.count - 1), at: UICollectionViewScrollPosition.top, animated: true)
        }

        dataSource.supplementaryViewFactory = { dataSource, collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.questionCollectionReusableView, for: indexPath)!
            header.questionLabel.text = dataSource.sectionModels[indexPath.section].model
            return header
        }

        questionsCollectionView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [unowned self] indexPath in
                self.dataSource[indexPath.section].items.enumerated()
                    .forEach { (offset, element) in
                        element.isSelected.value = offset == indexPath.row
                }
                self.questions.value.append(self.createQuestion(for: self.questions.value.count + 1))
            })
            .disposed(by: rx.disposeBag)
        
        questionsCollectionView.rx.setDelegate(self).disposed(by: rx.disposeBag)

        questions.asObservable()
            .bindTo(questionsCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        let result = questions.asObservable().map { $0.flatMap { $0.items } }
            .flatMap { options -> Observable<[Int]> in
                Observable.combineLatest(options.map { option in
                    option.isSelected.asObservable().map { (isSelected: $0, id: option.id) }
                }) { $0.flatMap { ($0.isSelected ?? false) ? $0.id : nil }  }
        }
        
        doneBarButtonItem.rx.tap.asObservable()
            .withLatestFrom(result)
            .map { $0.map { "\($0)" }.joined(separator: ",") }
            .flatMap { showAlert(title: nil, message: $0) }
            .subscribe(onNext: { [unowned self] in
                self.questions.value = self.defaultQuestions
            })
            .disposed(by: rx.disposeBag)

    }
    
    var defaultQuestions: [QuestionSectionModel] {
        return [createQuestion(for: 1)]
    }

    func createQuestion(for index: Int) -> QuestionSectionModel {
        return QuestionSectionModel(model: "问题 \(index)", items: [
            Option(id: index * 10 + 1, image: R.image.dianqk()!),
            Option(id: index * 10 + 2, image: R.image.dianqk()!),
            Option(id: index * 10 + 3, image: R.image.dianqk()!),
            Option(id: index * 10 + 4, image: R.image.dianqk()!),
            Option(id: index * 10 + 5, image: R.image.dianqk()!)
            ])
    }

}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section == (self.dataSource.sectionModels.count - 1)
    }
    
}
