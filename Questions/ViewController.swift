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

struct Option: IDHashable, IdentifiableType {
    let id: Int
    let image: UIImage
}

typealias QuestionSectionModel = AnimatableSectionModel<String, Option>

class ViewController: UIViewController {

    @IBOutlet weak var questionsCollectionView: UICollectionView! {
        didSet {
            questionsCollectionView.allowsSelection = true
        }
    }

    let questions: Variable<[QuestionSectionModel]> = Variable([])

    let dataSource = RxCollectionViewSectionedAnimatedCompletedDataSource<QuestionSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()

        questions.value = [
            QuestionSectionModel(model: "问题 1", items: [
                Option(id: 11, image: R.image.dianqk()!),
                Option(id: 12, image: R.image.dianqk()!),
                Option(id: 13, image: R.image.dianqk()!),
                Option(id: 14, image: R.image.dianqk()!),
                Option(id: 15, image: R.image.dianqk()!)
                ])
        ]

        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .automatic, deleteAnimation: .automatic)

        dataSource.configureCell = { dataSource, collectionView, indexPath, element in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.optionCollectionViewCell, for: indexPath)!
            cell.displayImageView.image = element.image
            return cell
        }

        dataSource.performBatchUpdatesCompletion = {
            self.questionsCollectionView.scrollToItem(at: IndexPath.init(row: 0, section: self.questions.value.count - 1), at: UICollectionViewScrollPosition.top, animated: true)
        }

        dataSource.supplementaryViewFactory = { dataSource, collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.reuseIdentifier.questionCollectionReusableView, for: indexPath)!
            header.questionLabel.text = dataSource.sectionModels[indexPath.section].model
            return header
        }

        questionsCollectionView.rx.itemSelected.asObservable()
            .subscribe(onNext: { indexPath in
                self.questions.value.append(self.createQuestion(for: self.questions.value.count))
            })
            .addDisposableTo(rx.disposeBag)

        questions.asObservable()
            .bindTo(questionsCollectionView.rx.items(dataSource: dataSource))
            .addDisposableTo(rx.disposeBag)

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
