//
//  ExpandableItem.swift
//  PDF-Expert-Contents
//
//  Created by DianQK on 17/09/2016.
//  Copyright © 2016 DianQK. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import RxExtensions

struct ExpandableItem<Model: IdentifiableType & Hashable> {

    let model: Model
    let isExpanded: Variable<Bool>
    private let _subItems: Variable<[ExpandableItem]> = Variable([])
    let canExpanded: Bool
    private let disposeBag = DisposeBag()

    var subItems: Observable<[ExpandableItem]> {
        return self._subItems.asObservable()
    }
    
    init(model: Model, isExpanded: Bool, subItems: [ExpandableItem]) {
        self.model = model

        self.canExpanded = !subItems.isEmpty
        if self.canExpanded {

            self.isExpanded = Variable(isExpanded)

            let displaySubItems = Variable<[ExpandableItem]>([])
            // 一次绑定
            _subItems.asObservable().filter { !$0.isEmpty }.bindTo(displaySubItems).disposed(by: disposeBag)
            // 1. combine
            combineSubItems(subItems).asObservable().bindTo(_subItems).disposed(by: disposeBag)
            // 2. handle expand
            // 不要交换 1 2 的顺序
            self.isExpanded.asObservable()
                .map { isExpanded in
                    isExpanded ? displaySubItems.value : []
                }
                .bindTo(_subItems)
                .disposed(by: disposeBag)

        } else {
            self.isExpanded = Variable(false)
        }


    }

    let combineSubItems: (_ subItems: [ExpandableItem]) -> Observable<[ExpandableItem]> = { subItems in
        return subItems.reduce(Observable<[ExpandableItem]>.just([])) { (acc, x) in
            Observable.combineLatest(acc, Observable.just([x]), x._subItems.asObservable(), resultSelector: { $0 + $1 + $2 })
        }
    }

}

extension ExpandableItem: IdentifiableType, Equatable, Hashable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: ExpandableItem, rhs: ExpandableItem) -> Bool {
        return lhs.model == rhs.model
    }

    var hashValue: Int {
        return model.hashValue
    }

    var identity: Model.Identity {
        return model.identity
    }

}
