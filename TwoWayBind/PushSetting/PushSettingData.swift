//
//  PushSettingData.swift
//  RxDealCell
//
//  Created by DianQK on 8/8/16.
//  Copyright © 2016 T. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let pushSettingData: [PushSettingSectionModel] = {

    let consumption = PushSectionModel(category: "消费相关", isSelectedAll: Variable(true))

    let consumptionItems = [
        PushItemModel(pushType: PushType.confirm, isSelected: Variable(true)),
        PushItemModel(pushType: PushType.willExpire, isSelected: Variable(true)),
        PushItemModel(pushType: PushType.expired, isSelected: Variable(true)),
        PushItemModel(pushType: PushType.refunded, isSelected: Variable(true)),
    ]
    let consumptionSection = PushSettingSectionModel(model: consumption, items: consumptionItems)

    let other = PushSectionModel(category: "其他", isSelectedAll: Variable(true))
    let otherItems = [
        PushItemModel(pushType: PushType.getGift, isSelected: Variable(true)),
        PushItemModel(pushType: PushType.couponInfo, isSelected: Variable(true)),
        PushItemModel(pushType: PushType.favorite, isSelected: Variable(true)),
    ]
    let otherSection = PushSettingSectionModel(model: other, items: otherItems)

    return [consumptionSection, otherSection]
}()
