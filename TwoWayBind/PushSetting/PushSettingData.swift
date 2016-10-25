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

    let consumptionItems = [
        PushItemModel(pushType: .confirm, select: Variable(true)),
        PushItemModel(pushType: .willExpire, select: Variable(true)),
        PushItemModel(pushType: .expired, select: Variable(true)),
        PushItemModel(pushType: .refunded, select: Variable(true)),
    ]
    let consumptionSection = PushSettingSectionModel(model: "消费相关", items: consumptionItems)

    let otherItems = [
        PushItemModel(pushType: .getGift, select: Variable(true)),
        PushItemModel(pushType: .couponInfo, select: Variable(true)),
        PushItemModel(pushType: .favorite, select: Variable(true)),
    ]
    let otherSection = PushSettingSectionModel(model: "其他", items: otherItems)

    return [consumptionSection, otherSection]
}()
