//
//  CollectionState.swift
//  ReduxDemo
//
//  Created by DianQK on 03/11/2016.
//  Copyright © 2016 T. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxExtensions

struct IconItem: IDHashable, IdentifiableType {

    let id: Int64
    let logo: Variable<UIImage>
    let title: Variable<String>

    init(id: Int64, logo: UIImage, title: String) {
        self.id = id
        self.logo = Variable(logo)
        self.title = Variable(title)
    }

}

struct CollectionState: ReducerAction {

    typealias ActionType = CollectionAction

    lazy private(set) var isEditing = Variable(false)
    lazy private(set) var elements =  Variable<[IconItem]>((1...10).map { IconItem(id: $0, logo: R.image.dianQK()!, title: "\($0)") })

    mutating func reducer(_ action: CollectionAction) {
        switch action {
        case let .add(item):
            elements.value.append(item)
        case let .remove(item):
            guard let index = self.elements.value.index(of: item) else { return }
            self.elements.value.remove(at: index)
        case let .move(sourceIndex, destinationIndex):
            var value = self.elements.value
            let temp = value.remove(at: sourceIndex)
            value.insert(temp, at: destinationIndex)
            self.elements.value = value
        case .done:
            self.isEditing.value = false
        case .edit:
            self.isEditing.value = true
        case .change:
            self.isEditing.reversed()
        }
    }

}
